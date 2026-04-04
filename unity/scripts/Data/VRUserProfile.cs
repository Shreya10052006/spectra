using System;
using System.Collections.Generic;
using UnityEngine;

namespace Spectra.VR.Data
{
    [Serializable]
    public class VRUserProfile
    {
        public string name;
        public string age_group;
        public string role;
        public string noise_sensitivity;
        public string social_comfort;
        public string communication;
        public List<string> triggers;
        public List<string> interests;

        // Fallback robust constructor
        public static VRUserProfile CreateFallback()
        {
            return new VRUserProfile
            {
                name = "Friend",
                noise_sensitivity = "neutral",
                social_comfort = "neutral",
                communication = "both",
                triggers = new List<string>(),
                interests = new List<string>()
            };
        }

        public static VRUserProfile ParseStrict(string json)
        {
            if (string.IsNullOrEmpty(json)) return CreateFallback();
            try
            {
                VRUserProfile profile = JsonUtility.FromJson<VRUserProfile>(json);
                
                // Fallback checks for missing required fields
                if (string.IsNullOrEmpty(profile.noise_sensitivity)) profile.noise_sensitivity = "neutral";
                if (string.IsNullOrEmpty(profile.social_comfort)) profile.social_comfort = "neutral";
                if (profile.triggers == null) profile.triggers = new List<string>();
                
                return profile;
            }
            catch (Exception e)
            {
                Debug.LogWarning($"[VRUserProfile] Failed to parse JSON, applying safe fallback. Error: {e.Message}");
                return CreateFallback();
            }
        }
    }
}
