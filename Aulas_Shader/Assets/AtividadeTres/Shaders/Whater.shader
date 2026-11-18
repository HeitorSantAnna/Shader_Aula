Shader "Custom/Whater"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Slider ("Slider", Range(0, 1)) = 0.5
    }
    SubShader
    {
        GrabPass {"_GrabTexture"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex, _GrabTexture;

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 recorte: TEXCOORD1;
            };

            fixed4 _Color;
            float4 _MainTex_ST, _GrabTexture_ST;
            float _Slider;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.recorte = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i): SV_Target
            {
                float4 col = tex2Dproj(_GrabTexture, i.recorte); 
                float4 col1 = tex2D(_GrabTexture, i.uv);

                return col.r;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
