Shader "Animated/Waving"
{
	Properties
	{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_CausticTex("Caustic", 2D) = "white" {}
		_NoiseTex("Noise text", 2D) = "bump" {}
		_offset("Offset", Range(0.0, 1.0)) = 0.5
		_waterMagnitude("Magnitude", Range(0.0, 1.0)) = 0.5
		_waterPeriod("Period", Range(0.0, 360.0)) = 180
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
			sampler2D _CausticTex;
			sampler2D _NoiseTex;

			float _offset;
			float _waterMagnitude;
			float _waterPeriod;

			struct vin_vct
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f_vct
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			float2 sinusoid(float2 x, float2 m, float2 M, float2 p)
			{
				float2 e = M - m;
				float2 c = 3.1415 * 2.0 / p;
				return e / 2.0 * (1.0 + sin(x * c)) + m;
			}

			// Vertex function 
			v2f_vct vert(vin_vct v)
			{
				v2f_vct o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.vertex.y += sin(_Time[1] + v.vertex.x);
				return o;
			}

			// Fragment function
			fixed4 frag(v2f_vct i) : COLOR
			{
				fixed4 noise = tex2D(_NoiseTex, i.texcoord);
				fixed4 mainColour = tex2D(_MainTex, i.texcoord);

				float time = _Time[1];

				float2 waterDisplacement = sinusoid (float2 (time, time) + (noise.xy) * _offset,
													 float2(-_waterMagnitude, -_waterMagnitude),
													 float2(+_waterMagnitude, +_waterMagnitude),
													 float2(_waterPeriod, _waterPeriod));

				fixed4 causticColour = tex2D(_CausticTex, i.texcoord.xy*0.25 + waterDisplacement * 5);
				return mainColour * causticColour;
			}

			ENDCG
		}
	}
}