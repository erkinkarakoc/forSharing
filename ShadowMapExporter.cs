using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class ShadowMapExporter : MonoBehaviour
{
   public Shader shadowMapShader; // Assign your shadow map shader in the inspector
    private Material shadowMapMaterial;
    private RenderTexture shadowMapTexture;

    void Start()
    {
        // Create a new material with the shadow map shader
        shadowMapMaterial = new Material(shadowMapShader);
        // Create a new RenderTexture to store the shadow map
        shadowMapTexture = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            CaptureShadowMap();
        }
    }

    void CaptureShadowMap()
    {
        // Set the target RenderTexture and render with the shadow map shader
        Graphics.SetRenderTarget(shadowMapTexture);
        GL.Clear(true, true, Color.clear);
        Graphics.Blit(null, shadowMapTexture, shadowMapMaterial);

        // Read pixels from the RenderTexture
        Texture2D tex = new Texture2D(shadowMapTexture.width, shadowMapTexture.height, TextureFormat.RGB24, false);
        RenderTexture.active = shadowMapTexture;
        tex.ReadPixels(new Rect(0, 0, shadowMapTexture.width, shadowMapTexture.height), 0, 0);
        tex.Apply();

        // Save to PNG
        string absolutePath = "D:/ShadowMap.png";
        byte[] bytes = tex.EncodeToPNG();
        System.IO.File.WriteAllBytes(absolutePath, bytes);

        // Clean up
        Destroy(tex);

        Debug.Log("Shadow map exported to ShadowMap.png");
    }
}
