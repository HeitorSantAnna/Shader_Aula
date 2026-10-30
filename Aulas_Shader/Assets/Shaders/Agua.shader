Shader "Custom/Agua"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SliderX ("Slider em X", Range(-1, 1)) = 0
        _SliderY ("Slider em Y", Range(-1, 1)) = 0
        _SliderZ ("Sliedr em Z", Range(-10, 10)) = 0

        _SliderA ("Slider em A", Range(-10, 10)) = 0
        _SliderC ("Slider em C", Range(-10, 10)) = 0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;
        float _SliderX, _SliderY, _SliderZ, _SliderA, _SliderC;

        inline float2 unity_voronoi_noise_randomVector (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)) * 46839.32);
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void VoronoiF(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float voronoi;
            float cell;
            VoronoiF(v.texcoord, _SliderA, _SliderC, voronoi, cell);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
