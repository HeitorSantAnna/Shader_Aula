Shader "Custom/HeatVision"
{   
    Properties
    {
        _R ("Vermelho", Range(0, 1)) = 0
        _G ("Verde", Range(0, 1)) = 0
        _B ("Azul", Range(0, 1)) = 0
        _Slider ("Slider", Range(0, 1)) = 0
        _UvX ("Mover Uv em X", Range(0, 1)) = 0
        _UvY ("Mover Uv em Y", Range(0, 1)) = 0
        _MainTex ("Main textura", 2D) = "white" {}
        _EnemyView ("Inimigos", 2D) = "White" {}

        [Toggle] _View ("Visualizar Inimigos", Float) = 0
    }
    SubShader
    {
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
        ENDHLSL

        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        ZWrite Off Cull Off
        Pass
        {
            Name "HeatVision"

            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            HLSLPROGRAM
            
            #pragma vertex Vert
            #pragma fragment Frag

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_EnemyView);
            SAMPLER(sampler_EnemyView);

            float _R, _G, _B, _Slider, _UvX, _UvY, _View;

            float4 Frag (Varyings input) : SV_Target
            {
                float4 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord).rgba;

                float4 eneColor = SAMPLE_TEXTURE2D(_EnemyView, sampler_EnemyView, input.texcoord).rgba;

                float4 circular = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord).rgba;

                //Espiral
                /*
                float2 uvs = input.texcoord;

                uvs.x += sin(uvs.y + 0.1 * _Time.y);
                uvs.y += sin(uvs.x + 0.1 * _Time.y);

                float4 spiral = SAMPLE_TEXTURE2D(_TwrilTex, sampler_TwrilTex, input.texcoord).rgba;

                float4 col = float4(_R, _G, _B, 1);

                col.a = spiral.r;

                return col;
                */

                //OutLine
                
                //TelaPrincipal
                /*
                half4 colorO = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord).rgba;
                half4 colorT = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord - half2(_UvX, _UvY)).rgba;
                

                half4 colorO = SAMPLE_TEXTURE2D(_EnemyView, sampler_EnemyView, input.texcoord).rgba;
                half4 colorT = SAMPLE_TEXTURE2D(_EnemyView, sampler_EnemyView, input.texcoord - half2(_UvX, _UvY)).rgba;


                half dist = length(colorT - colorO);

                half4 c = (dist > 0.2) ? 0:1;

                c.a = 1.0;
       
                return color + lerp(c, colorO, _Slider);
                */

                if(_View)
                {
                    return color + (eneColor * circular);
                }
                else
                {
                    return color;
                }
            }
            
            ENDHLSL
        }
    }
}
