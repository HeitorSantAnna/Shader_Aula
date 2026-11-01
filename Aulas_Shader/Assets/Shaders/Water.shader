Shader "Custom/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SliderX ("Slider em X", Range(0, 1)) = 0.5
        _SliderY ("Slider em Y", Range(-10, 10)) = 0
        _SliderZ ("Slider em Z", Range(-10, 10)) = 0
        _SliderF ("Slider em F", Range(1, 100)) = 10
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 color: COLOR;
        };

        fixed4 _Color;

        float _SliderX, _SliderY, _SliderZ, _SliderF;

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

        void SimpleNoiseF(float2 UV, float Scale, out float Out)
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

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            o.color = v.color;

            float f = v.color * v.texcoord.y;

            v.vertex.xyz += v.color * v.normal.xyz * sin(f * 0.1 * _Time.y);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            float noise;

            SimpleNoiseF(IN.uv_MainTex, _SliderF, noise);

            float f = _SliderX * IN.uv_MainTex.x + _SliderY;

            float m = (f * f) * -1 + _SliderZ;

            o.Albedo = IN.color * float3(noise, noise, m);

            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
