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
        Pass
        {
            CGPROGRAM
            
            #pragma fragment frag
            #pragma vertex vert
            #include "UnityCG.cginc"

            sampler2D _MainTex, _TexGrass, _TexRock, _TexMoss;

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

            float4 _MainTex_ST;

            float _Heigth, _Lower, _Higher;

            //Usar um float para mover o offset
            float2 _Offset;

            //Aqui fica o codigo do simple noise a ideia é usalo para determinar a altura e as cores

            inline float unity_noise_randomValue (float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
            }

            inline float unity_noise_interpolate (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }

            inline float unity_valueNoise (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);

                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = unity_noise_randomValue(c0);
                float r1 = unity_noise_randomValue(c1);
                float r2 = unity_noise_randomValue(c2);
                float r3 = unity_noise_randomValue(c3);

                float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
                float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
                float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
                return t;
            }

            void SimpleNoiseHeight(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;

                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                Out = t;
            }

            void SimpleNoiseTriplanar(float3 worldPos, float3 normal, float Scale, out float t)
            {
                float3 blend = abs(normal);

                blend /= (blend.x + blend.y + blend.z);

                float noisex, noisey, noisez;

                SimpleNoiseHeight(worldPos.zy, Scale, noisex);
                SimpleNoiseHeight(worldPos.xz, Scale, noisey);
                SimpleNoiseHeight(worldPos.xy, Scale, noisez);

                t = (noisex * blend.x + noisey * blend.y + noisez * blend.z);
            }

            //Vai ate aqio o simple noise

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 normal = UnityObjectToWorldNormal(v.normal);

                float f;

                SimpleNoiseTriplanar(worldPos, normal, 1, f);

                v.vertex.y = f * _Heigth;

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldPos = worldPos;

                o.normalWorld = normal;
                
                return o;
            }

            fixed4 frag (v2f i): SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);

                float4 grass = tex2D(_TexGrass, i.uv);

                float4 rock = tex2D(_TexRock, i.uv);

                float4 moss = tex2D(_TexMoss, i.uv);

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
            ENDCG
        }
    }
    FallBack "Diffuse"
}
