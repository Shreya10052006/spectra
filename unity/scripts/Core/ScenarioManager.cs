using System.Collections;
using UnityEngine;
using Spectra.VR.Data;

namespace Spectra.VR.Core
{
    public class ScenarioManager : MonoBehaviour
    {
        [Header("Data")]
        public ScenarioData CurrentScenario;
        private int _currentStageIndex = 0;

        [Header("Subsystems")]
        public NPCController NpcController;
        public PracticeManager PracticeManager;
        public UIManager UIMgr;

        [Header("Adaptive Variables")]
        private int _wrongAttemptsInStage = 0;
        private VRUserProfile _currentUserProfile;
        private SensoryManager _sensoryManager;

        private void Awake()
        {
            _sensoryManager = FindObjectOfType<SensoryManager>();
        }

        public void ApplyUserProfile(string jsonData)
        {
            Debug.Log($"[ScenarioManager] Received Flutter UserProfile: {jsonData}");
            _currentUserProfile = VRUserProfile.ParseStrict(jsonData);
            
            if (_sensoryManager != null)
            {
                _sensoryManager.SetSensoryLevel(_currentUserProfile.noise_sensitivity, _currentUserProfile.social_comfort);
            }

            // Adjust global pacing based on social comfort
            if (_currentUserProfile.social_comfort.Contains("uncomfortable") || 
                _currentUserProfile.communication.Contains("non-verbal"))
            {
                NpcController.SetPacingMultiplier(1.8f); // 80% slower
            }
            else if (_currentUserProfile.noise_sensitivity == "sensitive")
            {
                NpcController.SetPacingMultiplier(1.3f); // 30% slower
            }
        }

        private void Start()
        {
            if (CurrentScenario != null && CurrentScenario.Stages.Count > 0)
            {
                StartCoroutine(RunStage(CurrentScenario.Stages[0]));
            }
        }

        private IEnumerator RunStage(ScenarioStage stage)
        {
            // Initial setup for the stage
            UIMgr.ClearUI();
            NpcController.SetStateIdle();

            // 1. NPC Initial line (if any)
            if (!string.IsNullOrEmpty(stage.InitialNPCDialogue))
            {
                bool npcFine = false;
                NpcController.Speak(stage.InitialNPCDialogue, () => npcFine = true);
                yield return new WaitUntil(() => npcFine);
            }

            // 2. Situation Prompt
            NpcController.SetStateListening();
            UIMgr.ShowPrompt(stage.SituationPrompt);

            // 3. Decision Options Loop
            bool validDecisionMade = false;
            while (!validDecisionMade)
            {
                // Dynamic Adaptation: Reduce options if struggling or triggers exist
                var availableOptions = new System.Collections.Generic.List<DecisionOption>(stage.Options);
                if (_wrongAttemptsInStage >= 2 || (_currentUserProfile != null && _currentUserProfile.triggers.Contains("complex choices")))
                {
                    // Simplify: Remove non-ideal choices if the user struggles heavily
                    availableOptions.RemoveAll(o => !o.IsIdealChoice && availableOptions.Count > 1);
                    NpcController.SetPacingMultiplier(NpcController.GetPacingMultiplier() + 0.2f); // Slow down even further
                }

                DecisionOption chosenOption = null;
                UIMgr.ShowDecisionOptions(availableOptions, (opt) => chosenOption = opt);
                
                yield return new WaitUntil(() => chosenOption != null);
                UIMgr.HideDecisionOptions();

                // 4. Decision Logic & NPC Response
                bool npcFeedbackDone = false;
                NpcController.Speak(chosenOption.NPCFeedbackText, () => npcFeedbackDone = true);
                yield return new WaitUntil(() => npcFeedbackDone);

                if (chosenOption.IsIdealChoice)
                {
                    validDecisionMade = true;
                    // Move to Practice Mode
                    yield return StartCoroutine(RunPracticeMode(chosenOption));
                }
                else
                {
                    _wrongAttemptsInStage++;
                    // Non-ideal choice. Allow retry. Calm UI update.
                    bool retryDecided = false;
                    UIMgr.ShowRetryOption(() => retryDecided = true);
                    yield return new WaitUntil(() => retryDecided);
                }
            }

            // Move seamlessly to next stage or completion
            _currentStageIndex++;
            if (_currentStageIndex < CurrentScenario.Stages.Count)
            {
                // Smooth transition block here (camera subtle movement or just wait)
                yield return new WaitForSeconds(1.0f);
                StartCoroutine(RunStage(CurrentScenario.Stages[_currentStageIndex]));
            }
            else
            {
                UIMgr.ShowCompletionMessage(CurrentScenario.CompletionMessage, RestartScenario, ExitScenario);
            }
        }

        private IEnumerator RunPracticeMode(DecisionOption option)
        {
            PracticeManager.StartPractice(option);
            
            UIMgr.ShowPrompt("You can try saying it out loud.");
            
            bool practiceResolved = false;
            
            while (!practiceResolved)
            {
                bool inputCaptured = false;
                
                // Show Mic button, Help button, and a "Continue" button
                UIMgr.ShowPracticeControls(
                    onMicPressed: () => inputCaptured = true,
                    onHelpPressed: () => {
                        string hint = PracticeManager.GetNextHint();
                        if (!string.IsNullOrEmpty(hint)) UIMgr.ShowHint(hint);
                    },
                    onContinuePressed: () => practiceResolved = true // User chooses to skip practice
                );

                yield return new WaitUntil(() => inputCaptured || practiceResolved);

                if (inputCaptured && !practiceResolved)
                {
                    UIMgr.SetMicState(false); // Disable while processing
                    
                    bool evalDone = false;
                    SpeechQuality resultingQuality = SpeechQuality.Good;
                    string feedback = "";

                    PracticeManager.SimulateSpeechInput((quality, msg) => {
                        evalDone = true;
                        resultingQuality = quality;
                        feedback = msg;
                    });

                    yield return new WaitUntil(() => evalDone);

                    UIMgr.ShowHint(feedback); // Using hint UI for feedback text

                    if (resultingQuality == SpeechQuality.Good)
                    {
                        yield return new WaitForSeconds(2f); // Let user read it
                        practiceResolved = true;
                    }
                    else
                    {
                        // Show options to Try Again or Continue
                        bool postFeedbackDecision = false;
                        UIMgr.ShowPracticePostFeedbackOptions(
                            onTryAgain: () => postFeedbackDecision = true,
                            onContinue: () => {
                                postFeedbackDecision = true;
                                practiceResolved = true;
                            }
                        );
                        yield return new WaitUntil(() => postFeedbackDecision);
                    }
                }
            }
            UIMgr.ClearPracticeControls();
        }

        private void RestartScenario()
        {
            _currentStageIndex = 0;
            _wrongAttemptsInStage = 0;
            StartCoroutine(RunStage(CurrentScenario.Stages[0]));
        }

        private void ExitScenario()
        {
            Debug.Log("[ScenarioManager] Exiting VR Scenario.");
            // Normally load Scene 0 or close app
        }
    }
}
