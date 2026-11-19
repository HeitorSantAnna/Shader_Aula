Shader "Custom/Force"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _SliderX ("Slide em X", Range(-10, 10)) = 0
        _SliderY ("Slide em Y", Range(-100, 100)) = 0
        _SliderZ ("Slide em Z", Range(-100, 100)) = 0

        _SliderXV ("Slider em X do Vertice", Range(-1, 1)) = 0
        _SliderYV ("Slider de Y do Vertice", Range(-100, 100)) = 0
        _SliderZV ("Slider de Z do Vertice", Range(-1, 1)) = 0 
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        float _SliderX, _SliderY, _SliderZ;

        float _SliderXV, _SliderYV, _SliderZV;

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float t = (v.texcoord.x * _SliderXV) - (v.texcoord.y * _SliderYV) + _Time.y;

            float d = sin(t);

            v.vertex.xyz += v.normal * d;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            half x = IN.uv_MainTex.x;

            float t = (IN.uv_MainTex.x * _SliderX) - (IN.uv_MainTex.y * _SliderY) + _SliderZ;

            float d = sin(t);

            fixed4 color = fixed4(0, 1, 1, 1);

            o.Emission = color;
            o.Alpha = d;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
