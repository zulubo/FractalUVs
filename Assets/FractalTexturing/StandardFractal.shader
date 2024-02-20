Shader "Custom/StandardFractal"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _MetallicGlossMap("Metallic/Glossiness", 2D) = "white" {}
        [NoScaleOffset] _BumpMap("Normal", 2D) = "bump" {}
        _BumpScale("Normal Scale", Float) = 1.0
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _Scale("Texture Scale", Float) = 100
        _MinScl("Minimum Scale", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        #pragma target 5.0

        sampler2D _MainTex;
        sampler2D _MetallicGlossMap;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _BumpScale;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        half _Scale;
        half _MinScl;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float d = max(_MinScl, log2(distance(_WorldSpaceCameraPos, IN.worldPos)));

            int step = floor(d);

            int pingpong = uint(abs(step)) % uint(2);

            float2 uvA = _Scale * IN.uv_MainTex / exp2(step + pingpong);
            float2 uvB = _Scale * IN.uv_MainTex / exp2(step + 1 - pingpong);

            float fac = frac(d);
            fac = pingpong ? 1 - fac : fac;

            float4 cA = tex2D(_MainTex, uvA);
            float4 metA = tex2D(_MetallicGlossMap, uvA);
            float3 nrmA = UnpackScaleNormal(tex2D(_BumpMap, uvA), _BumpScale);

            float4 cB = tex2D(_MainTex, uvB);
            float4 metB = tex2D(_MetallicGlossMap, uvB);
            float3 nrmB = UnpackScaleNormal(tex2D(_BumpMap, uvB), _BumpScale);

            float4 c = lerp(cA, cB, fac);

            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
