Shader "Custom/PunchFlame"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Raio ("Raio", Range(0, 1)) = 0
        _RaioN ("Raio negativo", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0.001, 0.1)) = 0.01
        _SmoothnessN ("Smoothness negativo", Range(0.001, 0.1)) = 0.01
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;
        float _Raio, _Smoothness, _RaioN, _SmoothnessN;

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            float2 center = IN.uv_MainTex - 0.5;

            float dist = length(center);

            float sphere = 1.0 - smoothstep((_Raio - _Smoothness), (_Raio + _Smoothness), dist);

            float negsphere = 1.0 - smoothstep((_RaioN - _SmoothnessN), (_RaioN + _SmoothnessN), dist);

            o.Albedo = fixed4(sphere, negsphere, 0, 0);

            o.Alpha = sin((sphere - negsphere));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
