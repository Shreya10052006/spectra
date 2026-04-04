using System.Collections.Generic;
using UnityEngine;

namespace Spectra.VR.Data
{
    [CreateAssetMenu(fileName = "NewScenario", menuName = "Spectra/Scenario Data")]
    public class ScenarioData : ScriptableObject
    {
        [Tooltip("The name of the scenario. E.g., 'Café Interaction'")]
        public string ScenarioName;

        [Tooltip("List of sequential stages that make up this scenario.")]
        public List<ScenarioStage> Stages = new List<ScenarioStage>();

        [Tooltip("Message displayed when all stages are completed successfully.")]
        [TextArea(2, 4)]
        public string CompletionMessage = "You completed this interaction.";
    }
}
