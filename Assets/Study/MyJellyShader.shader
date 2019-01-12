Shader "Custom/MyJellyShader" {
    
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ControlTime("Time", Float) = 0.0
        _ModelOrigin("Model Origin", Vector) = (0,0,0,0)
        _ImpactOrigin("Impact Origin", Vector) = (-5,0,0,0)
        _Frequency ("Frequency", Range(0, 1000)) = 10
        _Amplitude ("Amplitude", Range(0, 5)) = 0.2
        _WaveFalloff ("Wave Falloff", Range(1, 8)) = 4
        _MaxWaveDistortion ("Max Wave Distortion", Range(0.1, 2.0)) = 1
        _ImpactSpeed ("Impact Speed", Range(0, 10)) = 0.5
        _WaveSpeed ("Wave Speed", Range(-10, 10)) = -5
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
        float4 _ModelOrigin;
        float4 _ImpactOrigin;
        half _Frequency;
        half _Amplitude;
        half _WaveFalloff;
        half _MinWaveSize;
        half _MaxWaveDistortion;
        half _ImpactSpeed;
        half _WaveSpeed;
        
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void vert (inout appdata_base v) {
        
            float4 world_space_vertex = mul(unity_ObjectToWorld, v.vertex);
            
            float4 direction = normalize(_ModelOrigin - _ImpactOrigin);
            
            // 原点の位置を右にずらす
            //float4 origin = float4(1.0, 0.0, 0.0, 0.0);
            // 原点のx座標は1.0から始まり、_ImpactSpeedの係数を含む_Timeにより、少しづつ原点が左に移動する
            //float4 origin = float4(1.0 - _ControlTime * _ImpactSpeed, 0.0, 0.0, 0.0);
           
            float4 origin = _ImpactOrigin + _ControlTime * _ImpactSpeed * direction;
           
            // 原点との距離を定義
            float dist = distance(world_space_vertex, origin);
            // 非線形になるように調整(指数関数的に)
            dist = pow(dist, _WaveFalloff);
            // 距離による波の歪みの最大値を設定
            dist = max(dist, _MaxWaveDistortion);
            
            
            // ワールド座標からオブジェクト座標へ
            float4 l_ImpactOrigin = mul(unity_WorldToObject, _ImpactOrigin);
            float4 l_direction = mul(unity_WorldToObject, direction);
            
            // Magic
            //P - point
            //D - direction of line (unit length)
            //A - point in line

            //X - base of the perpendicular line

            //    P
            //   /|
            //  / |
            // /  v
            //A---X----->D

            //(P-A).D == |X-A|

            //X == A + ((P-A).D)D
            //Desired perpendicular: X-P
            float impactAxis = l_ImpactOrigin + dot((v.vertex - l_ImpactOrigin), l_direction);
            
            v.vertex.xyz += v.normal * sin(impactAxis * _Frequency + _ControlTime * _WaveSpeed) * _Amplitude * (1/dist);
            
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