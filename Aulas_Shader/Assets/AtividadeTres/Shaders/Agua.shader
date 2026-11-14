Shader "Custom/Agua"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Slider ("Slider", Range(-10, 10)) = 1
        _Slider2 ("Slider", Range(-10, 10)) = 1
    }
    SubShader
    {

        GrabPass {"_GrabTexture"}

        Pass
        {
            CGPROGRAM
            
            #pragma fragment frag
            #pragma vertex vert
            #include "UnityCG.cginc"

            sampler2D _MainTex, _GrabTexture;

            struct appdata
            {
                float2 uv: TEXCOORD0;
                float4 vertex: POSITION;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
                float4 recorte: TEXCOORD1;
            };

            fixed4 _Color;
            float4 _MainTex_ST, _GrabTexture_ST;
            float _Slider, _Slider2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.recorte = ComputeGrabScreenPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i): SV_Target
            {
                float4 col_grab = tex2Dproj(_GrabTexture, i.recorte); 
                float4 col = tex2D(_MainTex, i.uv) * _Color;

                //float diffi = length(col1 - col2);
                //return step(diffi, _Slider2) * col1;
                //return 1 - col;

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
