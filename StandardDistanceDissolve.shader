
Shader "Custom/StandardDistanceDissolve" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "bump" {}
		_MetallicTex ("Metallic Map", 2D) = "white" {}
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_EmissionTex ("Emission Map", 2D) = "white" {}
		_EmissionTint ("Emission Colour", Color) = (0,0,0,0)
		_EmissionIntensity("Emission Intensity", Float) = 1.0

		_NearClip ("Near Clip Distance", Float) = 0.0
		_NoiseAmount("Noise Amount", Float) = 1.0
		_NoiseThreshold("Noise Threshold", Float) = 0.0
		_NoiseScale ("Noise scale", Vector) = (1.0, 1.0, 1.0)
		_NoiseOffset ("Noise offset", Vector) = (1.0, 1.0, 1.0)
		_ScreenCentreThreshold("Screen Centre Threshold", Float) = 1.0
	}
	SubShader {
		Tags { "Queue" = "Geometry" "RenderType"="TransparentCutout" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard vertex:vert fullforwardshadows addshadow vertex:vert
		#pragma target 3.5

		sampler2D _MainTex;
		sampler2D _NormalTex;
		sampler2D _MetallicTex;
		sampler2D _EmissionTex;
		
		struct Input {
			float2 uv_MainTex : TEXCOORD0;
			float4 vertex : POSITION;
			float4 posWorld;
			float4 screenPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _NearClip;
		fixed4 _EmissionTint;
		half _EmissionIntensity;

		float _NoiseAmount;
		float _NoiseThreshold;
		float3 _NoiseScale;
		float3 _NoiseOffset;
		float _ScreenCentreThreshold;
		

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		float hash( float n )
		{
			return frac(sin(n)*43758.5453);
		}

		float noise( float3 x )
		{
			// The noise function returns a value in the range -1.0f -> 1.0f

			float3 p = floor(x);
			float3 f = frac(x);

			f = f*f*(3.0-2.0*f);
			float n = p.x + p.y*57.0 + 113.0*p.z;

			return lerp(
				lerp(
					lerp( hash(n+0.0), hash(n+1.0), f.x), 
					lerp( hash(n+57.0), hash(n+58.0), f.x), 
					f.y
				),
			    lerp(
					lerp( hash(n+113.0), hash(n+114.0), f.x),
			        lerp( hash(n+170.0), hash(n+171.0), f.x), 
					f.y
				), 
				f.z
			);
		}

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.posWorld = mul(unity_ObjectToWorld, v.vertex);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			
			float2 perspScreenPos = IN.screenPos.xy / IN.screenPos.w;
			float screenDist = length(perspScreenPos - 0.5);

			float ns = _NoiseAmount * ( noise(_NoiseOffset + _NoiseScale * IN.posWorld.xyz) - _NoiseThreshold );

			float cameraDist = length(IN.posWorld.xyz - _WorldSpaceCameraPos.xyz);
			clip( cameraDist + screenDist * _ScreenCentreThreshold - ns - _NearClip );

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Normal = UnpackNormal (tex2D (_NormalTex, IN.uv_MainTex));
			o.Metallic = tex2D (_MetallicTex, IN.uv_MainTex).r * _Metallic;
			o.Smoothness = tex2D (_MetallicTex, IN.uv_MainTex).a * _Glossiness;
			o.Emission = tex2D (_EmissionTex, IN.uv_MainTex) * _EmissionTint * _EmissionIntensity;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
