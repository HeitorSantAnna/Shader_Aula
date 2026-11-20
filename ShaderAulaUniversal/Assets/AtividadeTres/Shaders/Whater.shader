Shader "Custom/Whater"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Slider ("Slider", Range(1, 20)) = 1

        _Heigth ("Altura", Range(1, 10)) = 1
        _Lower ("Mais Baixo", Range(0.1, 0.3)) = 0.1
        _Higher ("Mais Alto", Range(0, 1)) = 0.5
        _Scale ("Scala", Range(0, 1)) = 0
        _Alt ("Altura Lago", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags {"Queue" = "Transparent"}
        GrabPass {"_GrabTexture"}
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Assets/AtividadeTres/Shaders/NoiseTrip.txt"

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
                float4 grabPos: TEXCOORD1;
                float3 normalWorld: TEXCOORD2;
                float3 worldPos: TEXCOORD3;
            };

            fixed4 _Color;
            float4 _MainTex_ST, _GrabTexture_ST;
            float _Slider;
            float _Heigth, _Lower, _Higher, _Scale, _Alt;

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 normals = UnityObjectToWorldNormal(v.normal);

                float noiset;

                SimpleNoiseTriplanar(worldPos, normals, 1.1, noiset);

                float s = sin(_Heigth + _Time.y) * _Scale + _Alt;

                v.vertex.y = s;

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.grabPos = ComputeGrabScreenPos(o.vertex);

                o.worldPos = worldPos;

                o.normalWorld = normals;

                return o;
            }

            fixed4 frag (v2f i): SV_Target
            {
                i.grabPos.x += sin((_Time.y + i.grabPos.y) * _Slider) / 20;

                float4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabPos)) * _Color;

                float noiset;

                SimpleNoiseTriplanar(i.worldPos, normalize(i.normalWorld), 1, noiset);

                if(noiset.r <= _Lower)
                {
                    return col;
                }
                else
                {
                    return fixed4(0, 0, 0, 0);
                }
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
