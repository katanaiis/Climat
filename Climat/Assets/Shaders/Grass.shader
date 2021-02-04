Shader "Interface3/Grass"
{
    Properties
    {
        _BottomColor("Bottom Color", Color) = (1, 1, 1, 1)
        _TopColor("Top Color", Color) = (1, 1, 1, 1)
        _BendRotationRandom("Bend Rotation Random", Range(0, 1)) = 0.2
        _BladeWidth("Blade Width", Float) = 0.05
        _BladeWidthRandom("Blade Width Random", Float) = 0.02
        _BladeHeight("Blade Height", Float) = 0.5
        _BladeHeightRandom("Blade Height Random", Float) = 0.3
        _TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
        _WindDistortionMap("Wind Distortion Map", 2D) = "white" {}
        _WindFrequency("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
        _WindStrength("Wind Strength", Float) = 1
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Autolight.cginc"
    #include "ShaderFunctions.cginc"
    #include "CustomTessellation.cginc"

    half4 _BottomColor, _TopColor;
    half _BendRotationRandom;
    half _BladeWidth, _BladeWidthRandom, _BladeHeight, _BladeHeightRandom;
    sampler2D _WindDistortionMap;
    half4 _WindDistortionMap_ST;
    half2 _WindFrequency;
    half _WindStrength;

    struct geometryOutput {
        half4 pos : SV_POSITION;
        half2 uv : TEXCOORD0;
    };

    geometryOutput VertexOutput(half3 pos, float2 uv) {
        geometryOutput o;
        o.pos = UnityObjectToClipPos(pos);
        o.uv = uv;
        return o;
    };

    [maxvertexcount(3)]
    void geo(triangle vertOutput IN[3], inout TriangleStream<geometryOutput> triStream) {
        half3 pos = IN[0].vertex; 
        
        half3 vNormal = IN[0].normal;
        half4 vTangent = IN[0].tangent;
        half3 vBinormal = cross(vNormal, vTangent) * vTangent.w;

        half3x3 tangentToLocal = half3x3(
            vTangent.x, vBinormal.x, vNormal.x,
            vTangent.y, vBinormal.y, vNormal.y,
            vTangent.z, vBinormal.z, vNormal.z
        );

        half3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI , half3(0, 0, 1));

        half3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzx) * UNITY_PI * 0.5 * _BendRotationRandom, half3(-1, 0, 0));

        half2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _Time.y * _WindFrequency;
        half2 windSample = (tex2Dlod(_WindDistortionMap, half4(uv, 0, 0)).rg * 2 - 1) * _WindStrength;
        half3 wind = normalize(half3(windSample.x, windSample.y, 0));

        half3x3 windRotation = AngleAxis3x3(windSample * UNITY_PI, wind);

        half3x3 transformationMatrix = mul(mul(mul(tangentToLocal, windRotation), facingRotationMatrix), bendRotationMatrix);
        
        half3x3 transformationMatrixFacing = mul(tangentToLocal, facingRotationMatrix);


        float height = (rand(pos.zyx) * 2 - 1) *_BladeHeightRandom + _BladeHeight;
        float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;

        triStream.Append(VertexOutput(
            pos + mul(transformationMatrixFacing, half3(width, 0, 0)),
            half2(0,0)
        ));
        triStream.Append(VertexOutput(
            pos + mul(transformationMatrixFacing, half3(-width, 0, 0)),
            half2(1, 0)
        ));
        triStream.Append(VertexOutput(
            pos + mul(transformationMatrix, half3(0, 0, height)),
            half2(0.5, 1)
        ));
    }

    ENDCG

    SubShader
    {
        Cull Off

        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.6
            #pragma geometry geo
            #pragma hull hull
            #pragma domain domain
            
            #include "Lighting.cginc"

            float4 frag (geometryOutput o) : COLOR
            {	
                return lerp(_BottomColor, _TopColor, o.uv.y);
            }
            ENDCG
        }
    }
}