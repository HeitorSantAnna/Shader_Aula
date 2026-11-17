Shader "Custom/Whater"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Slider ("Slider", Range(0, 1)) = 0.5

        _Heigth ("Altura", Range(1, 10)) = 1
        _Lower ("Mais Baixo", Range(0.1, 0.3)) = 0.1
        _Higher ("Mais Alto", Range(0.5, 1)) = 0.6
    }
    SubShader
    {
        GrabPass {"_GrabTexture"}
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Assets/AtividadeTres/Shaders/Noise.txt"

            sampler2D _MainTex, _GrabTexture;

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 recorte: TEXCOORD1;
                float3 worldNormal: TEXCOORD2;
                float3 worldPos: TEXCOORD3;
            };

            fixed4 _Color;
            float4 _MainTex_ST, _GrabTexture_ST;
            float _Slider;
            float _Heigth, _Lower, _Higher;

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 normals = UnityObjectToWorldNormal(v.normal);

                float f;

                SimpleNoiseTriplanar(worldPos, normals, 1, f);

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.recorte = ComputeGrabScreenPos(o.vertex);

                o.worldPos = worldPos;

                o.worldNormal = normals;

                return o;
            }

            fixed4 frag (v2f i): SV_Target
            {
                float4 water = tex2Dproj(_GrabTexture, i.recorte);
                float4 col = tex2D(_GrabTexture, i.uv) * _Color;

                float f;

                float s = saturate(sin(1 + _Time.y));

                SimpleNoiseTriplanar(i.worldPos, normalize(i.worldNormal), 1, f);

                return water * s;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
