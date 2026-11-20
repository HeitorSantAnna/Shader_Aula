Shader "Custom/Terrain"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _TexGrass ("Textura de Grama", 2D) = "white" {}
        _TexRock ("Textura de Pedra", 2D) = "white" {}
        _TexMoss ("Textura de Musgo", 2D) = "white" {}
        _Offset ("Offset (X, Y)", Vector) = (0, 0, 0, 0)
        _Heigth ("Altura", Range(1, 10)) = 1
        _Lower ("Mais Baixo", Range(0.1, 0.3)) = 0.1
        _Higher ("Mais Alto", Range(0.5, 1)) = 0.6
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            
            #pragma fragment frag
            #pragma vertex vert
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/AtividadeTres/Shaders/NoiseTrip.txt"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_TexGrass);
            SAMPLER(sampler_TexGrass);

            TEXTURE2D(_TexRock);
            SAMPLER(sampler_TexRock);

            TEXTURE2D(_TexMoss);
            SAMPLER(sampler_TexMoss);

            struct appdata
            {
                float2 uv: TEXCOORD0;
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
                float3 normalWorld: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)

            float4 _MainTex_ST;
            float _Heigth, _Lower, _Higher;
            float2 _Offset;

            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 worldPos = TransformObjectToWorld(v.vertex.xyz);

                float3 normal = TransformObjectToWorldNormal(v.normal);

                float f;

                SimpleNoiseTriplanar(worldPos, normal, 1, f);

                v.vertex.y = f * _Heigth;

                o.vertex = TransformObjectToHClip(v.vertex);

                o.worldPos = worldPos;

                o.normalWorld = normal;
                
                return o;
            }

            float4 frag (v2f i): SV_Target
            {
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                float4 grass = SAMPLE_TEXTURE2D(_TexGrass, sampler_TexGrass, i.uv);

                float4 rock = SAMPLE_TEXTURE2D(_TexRock, sampler_TexRock, i.uv);

                float4 moss = SAMPLE_TEXTURE2D(_TexMoss, sampler_TexMoss, i.uv);

                float f;

                SimpleNoiseTriplanar(i.worldPos, normalize(i.normalWorld), 1, f);

                if(f.r >= _Lower && f.r < _Higher)
                {
                    return grass;
                } 
                else if(f.r >= _Higher)
                {
                    return rock;
                }
                else if(f.r < _Lower && f.r > 0.1)
                {
                    return col;
                }
                else
                {
                    return moss;
                }
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
