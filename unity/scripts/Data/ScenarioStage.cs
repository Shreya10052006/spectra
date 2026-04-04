using System.Collections.Generic;
using UnityEngine;

namespace Spectra.VR.Data
{
    [System.Serializable]
    public class ScenarioStage
    {
        [Header("Context")]
        [Tooltip("Internal name for this stage, e.g., 'Order Drink'")]
        public string StageName;

        [Tooltip("The situation prompt displayed to the user. E.g., 'What would you like to do?'")]
        [TextArea(2, 4)]
        public string SituationPrompt;

        [Tooltip("The initial NPC line when entering this stage (can be empty if user initiates)")]
        [TextArea(2, 4)]
        public string InitialNPCDialogue;

        [Header("Choices")]
        public List<DecisionOption> Options = new List<DecisionOption>();
    }
}
