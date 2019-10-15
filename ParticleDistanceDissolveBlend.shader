// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ParticleDistanceDissolveBlend" 
{
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0

		_NearClip ("Near Clip Distance", Float) = 0.0
		_ScreenCentreThreshold("Screen Centre Threshold", Float) = 1.0
	}

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off

		SubShader 
		{
			Pass 
			{
				CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"
					#pragma target 2.0
					#pragma multi_compile_particles
					#pragma multi_compile_fog

					sampler2D _MainTex;
					fixed4 _TintColor;
					float _NearClip;
					
					float _ScreenCentreThreshold;
					
					struct VertexInput 
					{
						float4 vertex : POSITION;       //local vertex position
						float2 texcoord0 : TEXCOORD0;   //uv coordinates
						fixed4 color : COLOR; 
					};
 
					struct VertexOutput 
					{
						float4 vertex : SV_POSITION;              //screen clip space position and depth
						float2 uv0 : TEXCOORD0;                //uv coordinates
						float4 color : TEXCOORD2;
						float4 worldPos: TEXCOORD6;
						float4 screenPos: TEXCOORD5;
						UNITY_FOG_COORDS(3)                    //this initializes the unity fog
						#ifdef SOFTPARTICLES_ON
						float4 projPos : TEXCOORD4;
						#endif
					};
 
					VertexOutput vert (VertexInput v)
					{
						VertexOutput o = (VertexOutput)0;           
						UNITY_SETUP_INSTANCE_ID(v);
						UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
						
						o.uv0 = v.texcoord0;
						o.vertex = UnityObjectToClipPos(v.vertex);
						o.color = v.color * _TintColor;
						o.worldPos = mul (unity_ObjectToWorld, v.vertex);
						o.screenPos = ComputeScreenPos(o.vertex);
						#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
						#endif
						UNITY_TRANSFER_FOG(o,o.vertex);
						return o;
					}
 
					sampler2D_float _CameraDepthTexture;
					float _InvFade;
 
					fixed4 frag (VertexOutput IN) : SV_Target
					{
						float2 perspScreenPos = IN.screenPos.xy / IN.screenPos.w;
						float screenDist = length(perspScreenPos - 0.5);

						float cameraDist = length(IN.worldPos.xyz - _WorldSpaceCameraPos.xyz);
						IN.color.a *= clamp( cameraDist + screenDist * _ScreenCentreThreshold - _NearClip, 0.0, 1.0 );
				
						#ifdef SOFTPARTICLES_ON
							float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)));
							float partZ = IN.projPos.z;
							float fade = saturate (_InvFade * (sceneZ-partZ));
							IN.color.a *= fade;
						#endif

						fixed4 col = 2.0 * IN.color * tex2D(_MainTex, IN.uv0);
						UNITY_APPLY_FOG(IN.fogCoord, col);

						return col;
					}
				 ENDCG 
			 }
		 }
	 }
 }