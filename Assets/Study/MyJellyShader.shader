Shader "Custom/MyJellyShader" {
    
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ControlTime("Time", Float) = 0.0
    }
    
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _ControlTime;
        static half _Frequency = 10;
        static half _Amplitude = 0.15;
        static half _WaveFalloff = 4;
        static half _MinWaveSize = 1;
        static half _MaxWaveDistortion = 1;
        static half _ImpactSpeed = 0.3;
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void vert (inout appdata_base v) {
            float4 world_space_vertex = mul(unity_ObjectToWorld, v.vertex);
            // 原点の位置を右にずらす
            //float4 origin = float4(1.0, 0.0, 0.0, 0.0);
            // 原点のx座標は1.0から始まり、_ImpactSpeedの係数を含む_Timeにより、少しづつ原点が左に移動する
            float4 origin = float4(1.0 - _ControlTime * _ImpactSpeed, 0.0, 0.0, 0.0);
            // 原点との距離を定義
            float dist = distance(world_space_vertex, origin);
            // 非線形になるように調整(指数関数的に)
            dist = pow(dist, _WaveFalloff);
            // 距離による波の歪みの最大値を設定
            dist = max(dist, _MaxWaveDistortion);
            
            //v.vertex.xyz += v.normal * sin(v.vertex.x * _Frequency + _Time.y) * _Amplitude;
            // (1/dist)を掛ける
            v.vertex.xyz += v.normal * sin(v.vertex.x * _Frequency + _ControlTime) * _Amplitude * (1/dist);
            
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    
    FallBack "Diffuse"
}