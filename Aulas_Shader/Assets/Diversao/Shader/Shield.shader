Shader "Custom/Shield"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
                float4 vertex: SV_POSITION;
                float3 viewPos: TEXCOORD2;
            };

            fixed4 _Color;

            fixed4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.vertex = UnityObjectToClipPos(v.vertex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i): SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                float3 d = GetViewForwardDir();

                return d;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
