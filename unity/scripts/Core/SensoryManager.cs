using System.Collections;
using UnityEngine;

namespace Spectra.VR.Core
{
    public class SensoryManager : MonoBehaviour
    {
        [Header("Audio Settings")]
        public AudioSource AmbientAudio;
        public float QuietVolume = 0.05f;
        public float NormalVolume = 0.2f;

        [Header("Lighting Settings")]
        public Light MainDirectionalLight;
        public float LowStimulationIntensity = 0.6f;
        public float NormalIntensity = 1.0f;

        [Header("Environment Settings")]
        public GameObject[] BackgroundNPCs;
        
        private string _targetSensitivity = "neutral";
        private Coroutine _transitionRoutine;

        public void SetSensoryLevel(string noiseSensitivity, string socialComfort)
        {
            _targetSensitivity = noiseSensitivity.ToLower();
            
            if (_transitionRoutine != null)
                StopCoroutine(_transitionRoutine);
                
            _transitionRoutine = StartCoroutine(SmoothTransition(socialComfort.ToLower()));
        }

        private IEnumerator SmoothTransition(string socialComfort)
        {
            // Determine targets
            float targetVolume = NormalVolume;
            float targetLight = NormalIntensity;
            int targetNpcCount = BackgroundNPCs != null ? BackgroundNPCs.Length : 0;

            if (_targetSensitivity == "sensitive")
            {
                targetVolume = QuietVolume;
                targetLight = LowStimulationIntensity;
            }
            
            if (socialComfort == "uncomfortable") targetNpcCount = 0;
            else if (socialComfort == "sometimes uncomfortable") targetNpcCount = Mathf.Min(1, targetNpcCount);

            float currentVolume = AmbientAudio != null ? AmbientAudio.volume : targetVolume;
            float currentLight = MainDirectionalLight != null ? MainDirectionalLight.intensity : targetLight;

            float duration = 2.5f;
            float elapsed = 0f;

            Debug.Log($"[SensoryManager] Transitioning -> Audio: {targetVolume}, Light: {targetLight}, NPCs: {targetNpcCount}");

            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = elapsed / duration;

                if (AmbientAudio != null)
                    AmbientAudio.volume = Mathf.Lerp(currentVolume, targetVolume, t);
                
                if (MainDirectionalLight != null)
                    MainDirectionalLight.intensity = Mathf.Lerp(currentLight, targetLight, t);

                yield return null;
            }

            // Smoothly enable/disable NPCs at the end of the transition or alpha fade if materials supported.
            // For now, toggle active states strictly matching requested count.
            if (BackgroundNPCs != null)
            {
                for (int i = 0; i < BackgroundNPCs.Length; i++)
                {
                    if (BackgroundNPCs[i] != null)
                    {
                        BackgroundNPCs[i].SetActive(i < targetNpcCount);
                    }
                }
            }
        }
    }
}
