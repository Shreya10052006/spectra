using System.Collections;
using UnityEngine;
using Spectra.VR.Data;

namespace Spectra.VR.Core
{
    public enum SpeechQuality
    {
        Good,
        NeedsImprovement,
        VeryUnclear
    }

    public class PracticeManager : MonoBehaviour
    {
        private DecisionOption _currentOption;
        private int _currentHintLevel = 0; // 0: None, 1: General, 2: Guided, 3: Direct

        public void StartPractice(DecisionOption option)
        {
            _currentOption = option;
            _currentHintLevel = 0;
            Debug.Log($"[Practice] Starting practice logic for option: {option.OptionText}");
        }

        public string GetNextHint()
        {
            if (_currentOption == null) return string.Empty;

            _currentHintLevel++;
            if (_currentHintLevel > 3) _currentHintLevel = 3; // Max out at Direct

            switch (_currentHintLevel)
            {
                case 1:
                    return _currentOption.PracticePromptGeneral;
                case 2:
                    return _currentOption.PracticePromptGuided;
                case 3:
                    return _currentOption.PracticePromptDirect;
                default:
                    return string.Empty;
            }
        }

        /// <summary>
        /// Simulates processing microphone input and evaluating it.
        /// </summary>
        public void SimulateSpeechInput(System.Action<SpeechQuality, string> onEvaluationComplete)
        {
            StartCoroutine(SimulateSTTRoutine(onEvaluationComplete));
        }

        private IEnumerator SimulateSTTRoutine(System.Action<SpeechQuality, string> onEvaluationComplete)
        {
            Debug.Log("[Practice] Listening to user speech...");
            yield return new WaitForSeconds(2.0f); // Simulate user speaking
            
            Debug.Log("[Practice] Processing speech...");
            yield return new WaitForSeconds(1.0f); // Simulate API call / STT decoding

            // Simulated evaluation logic (randomized for demonstration)
            float rand = Random.value;
            SpeechQuality quality;
            string feedbackMsg = "";

            if (rand > 0.4f) 
            {
                quality = SpeechQuality.Good;
                feedbackMsg = "That sounded good.";
            }
            else if (rand > 0.15f)
            {
                quality = SpeechQuality.NeedsImprovement;
                feedbackMsg = "Would you like a suggestion?";
            }
            else
            {
                quality = SpeechQuality.VeryUnclear;
                feedbackMsg = "Let's try that together.";
            }

            Debug.Log($"[Practice] Evaluation finished: {quality}. Message: {feedbackMsg}");
            onEvaluationComplete?.Invoke(quality, feedbackMsg);
        }
    }
}
