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
            #include "Assets/AtividadeTres/Shaders/NoiseTrip.txt"

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
