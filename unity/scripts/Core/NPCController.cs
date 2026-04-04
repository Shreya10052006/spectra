using System.Collections;
using UnityEngine;

namespace Spectra.VR.Core
{
    public class NPCController : MonoBehaviour
    {
        [Header("Components")]
        public Animator NpcAnimator;
        public AudioSource VoiceAudioSource;

        [Header("Procedural Realism")]
        public float BreathingSpeed = 1.5f;
        public float BreathingAmount = 0.005f;
        public float IdleRotationSpeed = 0.5f;
        public float IdleRotationAmount = 2.0f;

        private Vector3 _initialScale;
        private Quaternion _initialRotation;
        
        private float _pacingMultiplier = 1.0f;

        private static readonly int IsTalkingParam = Animator.StringToHash("IsTalking");
        private static readonly int IsListeningParam = Animator.StringToHash("IsListening");

        public void SetPacingMultiplier(float mult) => _pacingMultiplier = mult;
        public float GetPacingMultiplier() => _pacingMultiplier;

        private void Start()
        {
            _initialScale = transform.localScale;
            _initialRotation = transform.rotation;
        }

        private void Update()
        {
            // Simulate basic breathing expansion
            float breathe = Mathf.Sin(Time.time * BreathingSpeed) * BreathingAmount;
            transform.localScale = _initialScale + new Vector3(breathe, breathe, breathe);

            // Simulate slight idle shifting
            float shiftY = Mathf.Sin(Time.time * IdleRotationSpeed) * IdleRotationAmount;
            transform.rotation = _initialRotation * Quaternion.Euler(0, shiftY, 0);
        }

        public void SetStateIdle()
        {
            if (NpcAnimator != null)
            {
                NpcAnimator.SetBool(IsTalkingParam, false);
                NpcAnimator.SetBool(IsListeningParam, false);
            }
        }

        public void SetStateListening()
        {
            if (NpcAnimator != null)
            {
                NpcAnimator.SetBool(IsTalkingParam, false);
                NpcAnimator.SetBool(IsListeningParam, true);
            }
        }

        public void Speak(string dialogue, System.Action onComplete = null)
        {
            StopAllCoroutines();
            StartCoroutine(SpeakRoutine(dialogue, onComplete));
        }

        private IEnumerator SpeakRoutine(string dialogue, System.Action onComplete)
        {
            // Natural delay before speaking, influenced by pacing multiplier
            yield return new WaitForSeconds(Random.Range(0.6f, 1.2f) * _pacingMultiplier);

            if (NpcAnimator != null)
            {
                NpcAnimator.SetBool(IsListeningParam, false);
                NpcAnimator.SetBool(IsTalkingParam, true);
            }

            // Simulate speaking duration based on string length (approx 15 chars per sec), naturally slowed down
            float speakDuration = Mathf.Max(1.5f, dialogue.Length / (18f / _pacingMultiplier));
            
            // Simulating lip sync or speech action
            yield return new WaitForSeconds(speakDuration);

            if (NpcAnimator != null)
            {
                NpcAnimator.SetBool(IsTalkingParam, false);
            }

            // Natural pause after speaking, allowing user to process
            yield return new WaitForSeconds(0.8f * _pacingMultiplier);

            onComplete?.Invoke();
        }
    }
}
