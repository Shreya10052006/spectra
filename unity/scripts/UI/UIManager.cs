using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Spectra.VR.Data;

namespace Spectra.VR.Core
{
    /// <summary>
    /// Note: In Unity, this would tie into standard uGUI Canvas elements.
    /// This script acts as the structural interface for those elements.
    /// </summary>
    public class UIManager : MonoBehaviour
    {
        [Header("UI Panels")]
        public GameObject PromptPanel;
        public Text PromptText;
        public GameObject HintPanel;
        public Text HintText;

        [Header("Decision Options")]
        public Transform OptionsContainer;
        public GameObject OptionBtnPrefab; // Expected to have a Button and Text attached

        [Header("Practice Controls")]
        public GameObject PracticeControlPanel;
        public Button MicBtn;
        public Button HelpBtn;
        public Button ContinueBtn;

        [Header("Post Feedback Options")]
        public GameObject PostFeedbackPanel;
        public Button TryAgainBtn;
        public Button PostFeedbackContinueBtn;

        [Header("Retry / Next State Options")]
        public GameObject RetryPanel;
        public Button PrimaryRetryBtn;

        [Header("Completion")]
        public GameObject CompletionPanel;
        public Text CompletionText;
        public Button RestartBtn;
        public Button ExitBtn;

        public void ClearUI()
        {
            if (PromptPanel != null) PromptPanel.SetActive(false);
            if (HintPanel != null) HintPanel.SetActive(false);
            if (PracticeControlPanel != null) PracticeControlPanel.SetActive(false);
            if (PostFeedbackPanel != null) PostFeedbackPanel.SetActive(false);
            if (RetryPanel != null) RetryPanel.SetActive(false);
            if (CompletionPanel != null) CompletionPanel.SetActive(false);
            HideDecisionOptions();
        }

        public void ShowPrompt(string prompt)
        {
            if (PromptPanel != null)
            {
                PromptPanel.SetActive(true);
                if (PromptText != null) PromptText.text = prompt;
            }
            else
            {
                Debug.Log($"[UI Prompt] {prompt}");
            }
        }

        public void ShowHint(string hint)
        {
            if (HintPanel != null)
            {
                HintPanel.SetActive(true);
                if (HintText != null) HintText.text = hint;
            }
            else
            {
                Debug.Log($"[UI Hint] {hint}");
            }
        }

        public void ShowDecisionOptions(List<DecisionOption> options, System.Action<DecisionOption> onOptionSelected)
        {
            // In a real Unity app, this instantiates buttons into the container.
            // For now, logging the interface expectations.
            Debug.Log("[UI] Showing Decision Options:");
            foreach (var opt in options)
            {
                Debug.Log($" - {opt.OptionText}");
            }
            
            // Simulating a button press after delay for testing purposes if run standalone
            // StartCoroutine(MockUserClick(options[0], onOptionSelected)); 
            
            // Real implementation hooks up generic Unity Buttons in OptionsContainer
        }

        public void HideDecisionOptions()
        {
            Debug.Log("[UI] Hiding Decision Options");
            // Destroy child objects in OptionsContainer
        }

        public void ShowRetryOption(System.Action onRetryPressed)
        {
            if (RetryPanel != null)
            {
                RetryPanel.SetActive(true);
                PrimaryRetryBtn.onClick.RemoveAllListeners();
                PrimaryRetryBtn.onClick.AddListener(() => {
                    RetryPanel.SetActive(false);
                    onRetryPressed?.Invoke();
                });
            }
            else
            {
                Debug.Log("[UI] Provide Retry option to user");
            }
        }

        public void ShowPracticeControls(System.Action onMicPressed, System.Action onHelpPressed, System.Action onContinuePressed)
        {
            if (PracticeControlPanel != null)
            {
                PracticeControlPanel.SetActive(true);

                MicBtn.onClick.RemoveAllListeners();
                MicBtn.onClick.AddListener(() => onMicPressed?.Invoke());
                MicBtn.interactable = true;

                HelpBtn.onClick.RemoveAllListeners();
                HelpBtn.onClick.AddListener(() => onHelpPressed?.Invoke());

                ContinueBtn.onClick.RemoveAllListeners();
                ContinueBtn.onClick.AddListener(() => {
                    PracticeControlPanel.SetActive(false);
                    onContinuePressed?.Invoke();
                });
            }
            else
            {
                Debug.Log("[UI] Showing Practice Controls [MIC] [HELP] [CONTINUE]");
            }
        }

        public void SetMicState(bool interactable)
        {
            if (MicBtn != null) MicBtn.interactable = interactable;
        }

        public void ShowPracticePostFeedbackOptions(System.Action onTryAgain, System.Action onContinue)
        {
            if (PostFeedbackPanel != null)
            {
                PostFeedbackPanel.SetActive(true);

                TryAgainBtn.onClick.RemoveAllListeners();
                TryAgainBtn.onClick.AddListener(() => {
                    PostFeedbackPanel.SetActive(false);
                    onTryAgain?.Invoke();
                });

                PostFeedbackContinueBtn.onClick.RemoveAllListeners();
                PostFeedbackContinueBtn.onClick.AddListener(() => {
                    PostFeedbackPanel.SetActive(false);
                    onContinue?.Invoke();
                });
            }
            else
            {
                Debug.Log("[UI] Showing Practice Post Feedback [TRY AGAIN] [CONTINUE]");
            }
        }

        public void ClearPracticeControls()
        {
            if (PracticeControlPanel != null) PracticeControlPanel.SetActive(false);
            if (PostFeedbackPanel != null) PostFeedbackPanel.SetActive(false);
            if (HintPanel != null) HintPanel.SetActive(false);
        }

        public void ShowCompletionMessage(string message, System.Action onRestart, System.Action onExit)
        {
            ClearUI();
            if (CompletionPanel != null)
            {
                CompletionPanel.SetActive(true);
                if (CompletionText != null) CompletionText.text = message;

                RestartBtn.onClick.RemoveAllListeners();
                RestartBtn.onClick.AddListener(() => {
                    CompletionPanel.SetActive(false);
                    onRestart?.Invoke();
                });

                ExitBtn.onClick.RemoveAllListeners();
                ExitBtn.onClick.AddListener(() => onExit?.Invoke());
            }
            else
            {
                Debug.Log($"[UI] COMPLETION: {message}");
            }
        }
    }
}
