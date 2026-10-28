Shader "Custom/Teste"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _X ("Valor em X", Range(-10, 10)) = 0
        _Y ("Valor em Y", Range(-10, 10)) = 0
        _Z ("Valor em Z", Range(-20, 20)) = 0
    }
    SubShader
    {
        Tags {
            "Queue" = "Transparent" 
        
            "RenderType" = "Transparent"
            }

        Pass{
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert

            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 uv: TEXCOORD0;
                float4 vColor: COLOR;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 vColor: COLOR;
                float3 normal: NORMAL;
            };

            sampler2D _MainTex;

            float4 _MainTex_ST;

            float _X, _Y, _Z;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i): SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float3 c = _WorldSpaceCameraPos.xyz;
                if(dot(i.vertex.xyz, c) > 0.5)
                {
                    return (1, 1, 1, 1);
                } 
                else
                {
                    return (0, 0, 0, 0);
                }
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
