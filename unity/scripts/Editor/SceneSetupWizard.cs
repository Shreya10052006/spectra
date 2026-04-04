#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using Spectra.VR.Core;
using Spectra.VR.Data;
using System.Collections.Generic;
using System.IO;

namespace Spectra.VR.Editor
{
    public class SceneSetupWizard : EditorWindow
    {
        [MenuItem("Spectra/Build Minimal VR Scene (2-Step Cafe)")]
        public static void BuildScene()
        {
            // 1. Create a new empty scene
            var newScene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

            // 2. Setup Environment Lighting & Camera
            GameObject mainCamera = new GameObject("Main Camera", typeof(Camera), typeof(AudioListener));
            mainCamera.transform.position = new Vector3(0, 1.6f, -2);
            mainCamera.tag = "MainCamera";

            GameObject dirLightObj = new GameObject("Directional Light", typeof(Light));
            dirLightObj.transform.rotation = Quaternion.Euler(50, -30, 0);
            Light dirLight = dirLightObj.GetComponent<Light>();
            dirLight.type = LightType.Directional;
            dirLight.color = new Color(1f, 0.95f, 0.8f); // Warm cafe lighting
            dirLight.intensity = 1.0f;

            GameObject ambientAudio = new GameObject("Ambient Audio", typeof(AudioSource));
            AudioSource source = ambientAudio.GetComponent<AudioSource>();
            source.loop = true;
            source.volume = 0.2f;

            // 3. Create NPC (Cashier)
            GameObject npcObject = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            npcObject.name = "Cashier_NPC";
            npcObject.transform.position = new Vector3(0, 1, 1);
            npcObject.GetComponent<Renderer>().sharedMaterial.color = new Color(0.2f, 0.6f, 0.8f);
            NPCController npcController = npcObject.AddComponent<NPCController>();
            npcController.BreathingSpeed = 1.5f;
            npcController.BreathingAmount = 0.005f;

            // 4. Create Core Managers
            GameObject managersObj = new GameObject("VR_Managers");
            ScenarioManager scenarioManager = managersObj.AddComponent<ScenarioManager>();
            SensoryManager sensoryManager = managersObj.AddComponent<SensoryManager>();
            PracticeManager practiceManager = managersObj.AddComponent<PracticeManager>();

            sensoryManager.MainDirectionalLight = dirLight;
            sensoryManager.AmbientAudio = source;

            // 5. Build UIManager Canvas Hierarchy
            GameObject eventSystem = new GameObject("EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));
            
            GameObject canvasObj = new GameObject("WorldCanvas", typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
            Canvas canvas = canvasObj.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.WorldSpace;
            RectTransform canvasRect = canvasObj.GetComponent<RectTransform>();
            canvasRect.sizeDelta = new Vector2(800, 600);
            canvasRect.transform.position = new Vector3(0, 1.5f, 0);
            canvasRect.transform.localScale = new Vector3(0.002f, 0.002f, 0.002f);
            
            UIManager uiManager = managersObj.AddComponent<UIManager>();
            
            // Build Prompt Panel
            GameObject promptPanel = CreatePanel(canvasObj.transform, "PromptPanel", new Color(0.9f, 0.95f, 1f));
            uiManager.PromptPanel = promptPanel;
            uiManager.PromptText = CreateText(promptPanel.transform, "Situation Prompt", 36, Color.black).GetComponent<Text>();
            
            // Build Hint Panel
            GameObject hintPanel = CreatePanel(canvasObj.transform, "HintPanel", new Color(1f, 0.95f, 0.8f));
            hintPanel.GetComponent<RectTransform>().anchoredPosition = new Vector2(0, 150);
            uiManager.HintPanel = hintPanel;
            uiManager.HintText = CreateText(hintPanel.transform, "Hint appears here", 28, Color.black).GetComponent<Text>();

            // Build Options Container
            GameObject optionsContainer = new GameObject("OptionsContainer", typeof(RectTransform), typeof(VerticalLayoutGroup));
            optionsContainer.transform.SetParent(canvasObj.transform, false);
            VerticalLayoutGroup vlg = optionsContainer.GetComponent<VerticalLayoutGroup>();
            vlg.spacing = 15;
            vlg.childAlignment = TextAnchor.MiddleCenter;
            optionsContainer.GetComponent<RectTransform>().anchoredPosition = new Vector2(0, -100);
            uiManager.OptionsContainer = optionsContainer.transform;

            // Build Option Button Prefab (saved simply as a GameObject reference for now, dynamic instancing can use it)
            uiManager.OptionBtnPrefab = CreateButton(optionsContainer.transform, "OptionButton", "Option Text", new Color(0.4f, 0.6f, 0.8f));
            uiManager.OptionBtnPrefab.SetActive(false); // Hide the template

            // Build Retry Panel
            GameObject retryPanel = CreatePanel(canvasObj.transform, "RetryPanel", new Color(1f, 0.9f, 0.9f));
            retryPanel.GetComponent<RectTransform>().anchoredPosition = new Vector2(0, -150);
            uiManager.RetryPanel = retryPanel;
            uiManager.PrimaryRetryBtn = CreateButton(retryPanel.transform, "TryAgainBtn", "Try Again", new Color(0.8f, 0.4f, 0.4f)).GetComponent<Button>();

            // Build Practice Control Panel
            GameObject practicePanel = CreatePanel(canvasObj.transform, "PracticeControlPanel", new Color(0.9f, 0.9f, 0.95f));
            practicePanel.GetComponent<RectTransform>().anchoredPosition = new Vector2(0, -200);
            HorizontalLayoutGroup pVlg = practicePanel.AddComponent<HorizontalLayoutGroup>();
            pVlg.spacing = 20;
            pVlg.childAlignment = TextAnchor.MiddleCenter;
            uiManager.PracticeControlPanel = practicePanel;
            uiManager.MicBtn = CreateButton(practicePanel.transform, "MicBtn", "Speak (Simulate)", new Color(0.3f, 0.8f, 0.4f)).GetComponent<Button>();
            uiManager.HelpBtn = CreateButton(practicePanel.transform, "HelpBtn", "Need Help", new Color(0.8f, 0.7f, 0.2f)).GetComponent<Button>();
            uiManager.ContinueBtn = CreateButton(practicePanel.transform, "ContinueBtn", "Continue", new Color(0.5f, 0.5f, 0.5f)).GetComponent<Button>();

            // Build Post Feedback Options Panel
            GameObject postFeedbackPanel = CreatePanel(canvasObj.transform, "PostFeedbackPanel", new Color(0.9f, 0.95f, 0.9f));
            postFeedbackPanel.GetComponent<RectTransform>().anchoredPosition = new Vector2(0, -250);
            HorizontalLayoutGroup pfVlg = postFeedbackPanel.AddComponent<HorizontalLayoutGroup>();
            pfVlg.spacing = 20;
            uiManager.PostFeedbackPanel = postFeedbackPanel;
            uiManager.TryAgainBtn = CreateButton(postFeedbackPanel.transform, "TryAgainPostBtn", "Try Again", new Color(0.4f, 0.6f, 0.8f)).GetComponent<Button>();
            uiManager.PostFeedbackContinueBtn = CreateButton(postFeedbackPanel.transform, "PostContinueBtn", "Continue", new Color(0.3f, 0.8f, 0.4f)).GetComponent<Button>();

            // Completion Panel
            GameObject completePanel = CreatePanel(canvasObj.transform, "CompletionPanel", new Color(0.8f, 1f, 0.8f));
            uiManager.CompletionPanel = completePanel;
            uiManager.CompletionText = CreateText(completePanel.transform, "Completed", 48, Color.black).GetComponent<Text>();
            uiManager.RestartBtn = CreateButton(completePanel.transform, "RestartBtn", "Restart", new Color(0.4f, 0.6f, 0.8f)).GetComponent<Button>();
            uiManager.ExitBtn = CreateButton(completePanel.transform, "ExitBtn", "Exit", new Color(0.8f, 0.4f, 0.4f)).GetComponent<Button>();

            // Hide UI initially
            uiManager.ClearUI();

            // Link Core Subsystems
            scenarioManager.UIMgr = uiManager;
            scenarioManager.NpcController = npcController;
            scenarioManager.PracticeManager = practiceManager;

            // 6. Generate 2-Step Scenario Data ScriptableObject
            string dataPath = "Assets/Data";
            if (!Directory.Exists(dataPath))
            {
                Directory.CreateDirectory(dataPath);
            }

            ScenarioData scenarioData = ScriptableObject.CreateInstance<ScenarioData>();
            scenarioData.ScenarioName = "Cafe Interaction (2-Step)";
            scenarioData.CompletionMessage = "You completed the Cafe interaction nicely!";

            // Step 1
            ScenarioStage stage1 = new ScenarioStage();
            stage1.StageName = "Entry";
            stage1.SituationPrompt = "You enter a café. What would you like to do?";
            stage1.Options.Add(new DecisionOption() {
                OptionText = "Say hello", IsIdealChoice = true, NPCFeedbackText = "Hi! Welcome to the cafe.",
                PracticePromptGeneral = "You can try greeting.", PracticePromptGuided = "Try starting with 'Hello'", PracticePromptDirect = "Hello there."
            });
            stage1.Options.Add(new DecisionOption() {
                OptionText = "Walk away", IsIdealChoice = false, NPCFeedbackText = "Take your time. Return when you're ready."
            });
            scenarioData.Stages.Add(stage1);

            // Step 2
            ScenarioStage stage2 = new ScenarioStage();
            stage2.StageName = "Ordering";
            stage2.InitialNPCDialogue = "What would you like to order today?";
            stage2.SituationPrompt = "How do you respond?";
            stage2.Options.Add(new DecisionOption() {
                OptionText = "Ask politely", IsIdealChoice = true, NPCFeedbackText = "Sure, I can get that started for you.",
                PracticePromptGeneral = "Ask for what you want politely.", PracticePromptGuided = "Try starting with 'I would like'", PracticePromptDirect = "I would like a coffee please."
            });
            stage2.Options.Add(new DecisionOption() {
                OptionText = "Point silently", IsIdealChoice = false, NPCFeedbackText = "I see what you're pointing at, but could you tell me specifically?"
            });
            scenarioData.Stages.Add(stage2);

            string assetPath = "Assets/Data/CafeScenarioData.asset";
            AssetDatabase.CreateAsset(scenarioData, assetPath);
            AssetDatabase.SaveAssets();

            scenarioManager.CurrentScenario = scenarioData;

            // Mark Scene as dirty
            EditorSceneManager.MarkSceneDirty(newScene);
            Debug.Log("<color=green><b>SPECTRA VR Scene Successfully Built!</b></color>");
        }

        // --- Helper Methods ---

        private static GameObject CreatePanel(Transform parent, string name, Color color)
        {
            GameObject panel = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            panel.transform.SetParent(parent, false);
            RectTransform rect = panel.GetComponent<RectTransform>();
            rect.sizeDelta = new Vector2(700, 200);
            Image img = panel.GetComponent<Image>();
            img.color = color;
            return panel;
        }

        private static GameObject CreateText(Transform parent, string defaultText, int fontSize, Color color)
        {
            GameObject txtObj = new GameObject("Text", typeof(RectTransform), typeof(CanvasRenderer), typeof(Text));
            txtObj.transform.SetParent(parent, false);
            Text txt = txtObj.GetComponent<Text>();
            txt.text = defaultText;
            txt.fontSize = fontSize;
            txt.color = color;
            txt.alignment = TextAnchor.MiddleCenter;
            txtObj.GetComponent<RectTransform>().sizeDelta = new Vector2(600, 100);
            return txtObj;
        }

        private static GameObject CreateButton(Transform parent, string name, string label, Color color)
        {
            GameObject btnObj = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image), typeof(Button));
            btnObj.transform.SetParent(parent, false);
            RectTransform rect = btnObj.GetComponent<RectTransform>();
            rect.sizeDelta = new Vector2(200, 60);
            btnObj.GetComponent<Image>().color = color;

            GameObject txtObj = CreateText(btnObj.transform, label, 20, Color.white);
            txtObj.GetComponent<RectTransform>().sizeDelta = new Vector2(200, 60);

            return btnObj;
        }
    }
}
#endif
