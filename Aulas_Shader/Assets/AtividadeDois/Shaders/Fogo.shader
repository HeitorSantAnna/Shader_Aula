Shader "Custom/Fogo"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _TexCh ("Testura da Chama Interior", 2D) = "white" {}
        _Slider ("Slider de controle", Range(-10, 10)) = 0
        _SliderX ("Slider de X", Range(-1, 1)) = 0
        _SliderY ("Slider de Y", Range(-1, 1)) = 0
        _SliderZ ("Slider de Z", Range(-1, 1)) = 0
        _SliderF ("Slider de F", Range(-10, 10)) = 0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _TexCh;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_TexCh;
            float3 normal;
            float4 color: COLOR;
        };

        fixed4 _Color;
        float _Slider, _SliderX, _SliderY, _SliderZ, _SliderF;

        void TwirlF(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float angle = Strength * length(delta);
            float x = cos(angle) * delta.x - sin(angle) * delta.y;
            float y = sin(angle) * delta.x + cos(angle) * delta.y;
            Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
        }

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float2 twirl;
            TwirlF(v.texcoord, float2(_SliderX, _SliderZ), _SliderF, float2(_Slider, _SliderY), twirl);
            o.normal = v.normal;
            o.color = v.color;

            if(v.color.r > 0.5)
            {
                v.vertex.xz += twirl * sin(0.5 * _Time.y);
            }
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * fixed4(1, 0, 0, 1);
            fixed4 d = tex2D (_TexCh, IN.uv_TexCh) * fixed4(0, 1, 0, 1);

            o.Albedo = c + d;

            o.Emission = c;

            o.Alpha = c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
