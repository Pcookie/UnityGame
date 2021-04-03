using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class ShaderProperties
{
    public Color color;
    public Texture2D mainTex;

    public ShaderProperties(Color color, Texture2D mainTex)
    {
        this.color = color;
        this.mainTex = mainTex;
    }
}


[System.Serializable]
public class MaterialProperties
{
    public Material meterial;
    public List<ShaderProperties> properties;
    public int selectedProperty;

   public  MaterialProperties(Material material)
    {
        this.meterial = material;
        properties = new List<ShaderProperties>();
    }
}

public class IL3DN_ColorManagerTextures : MonoBehaviour
{
    public List<MaterialProperties> materials = new List<MaterialProperties>();
}
