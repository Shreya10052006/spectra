using UnityEngine;

namespace Spectra.VR.Data
{
    [System.Serializable]
    public class DecisionOption
    {
        [Tooltip("The text displayed on the UI button")]
        public string OptionText;

        [Tooltip("Is this the ideal option to progress smoothly?")]
        public bool IsIdealChoice;

        [Tooltip("The NPC's verbal reaction if this option is chosen")]
        [TextArea(2, 4)]
        public string NPCFeedbackText;

        [Header("Practice Settings (If Ideal)")]
        [Tooltip("The initial general prompt. E.g., 'You can try greeting'")]
        public string PracticePromptGeneral;

        [Tooltip("The guided hint. E.g., 'Try starting with Hello'")]
        public string PracticePromptGuided;

        [Tooltip("The direct example. E.g., 'Hello, I would like to order.'")]
        public string PracticePromptDirect;
    }
}
