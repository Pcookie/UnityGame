// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "IL3DN/Grass"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_AlphaCutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[Toggle(_WIND_ON)] _Wind("Wind", Float) = 1
		_WindStrenght("Wind Strenght", Range( 0 , 1)) = 0.5
		[Toggle(_WIGGLE_ON)] _Wiggle("Wiggle", Float) = 1
		_WiggleStrenght("Wiggle Strenght", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma multi_compile __ _WIND_ON
		#pragma multi_compile __ _WIGGLE_ON
		#pragma exclude_renderers xbox360 psp2 n3ds wiiu 
		#pragma surface surf Lambert keepalpha addshadow fullforwardshadows nolightmap  nodirlightmap dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float3 WindDirection;
		uniform float _WindStrenght;
		uniform float WindSpeedFloat;
		uniform float WindTurbulenceFloat;
		uniform float WindStrenghtFloat;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float GrassWiggleFloat;
		uniform float _WiggleStrenght;
		uniform float _AlphaCutoff;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float mulTime986 = _Time.y * 0.25;
			float2 temp_cast_0 = (mulTime986).xx;
			float simplePerlin2D985 = snoise( temp_cast_0 );
			float3 worldToObjDir1015 = mul( unity_WorldToObject, float4( (WindDirection).xzy, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 panner706 = ( 1.0 * _Time.y * ( worldToObjDir1015 * WindSpeedFloat ).xy + (ase_worldPos).xz);
			float simplePerlin2D712 = snoise( ( ( panner706 * 0.25 ) * WindTurbulenceFloat ) );
			float worldNoise1038 = simplePerlin2D712;
			float4 transform1029 = mul(unity_WorldToObject,float4( ( WindDirection * ( simplePerlin2D985 * ( _WindStrenght * ( ( v.color.a * worldNoise1038 ) + ( worldNoise1038 * v.color.g ) ) * WindStrenghtFloat ) ) ) , 0.0 ));
			#ifdef _WIND_ON
				float4 staticSwitch1031 = transform1029;
			#else
				float4 staticSwitch1031 = float4( 0,0,0,0 );
			#endif
			v.vertex.xyz += staticSwitch1031.xyz;
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 worldToObjDir1015 = mul( unity_WorldToObject, float4( (WindDirection).xzy, 0 ) ).xyz;
			float3 ase_worldPos = i.worldPos;
			float2 panner706 = ( 1.0 * _Time.y * ( worldToObjDir1015 * WindSpeedFloat ).xy + (ase_worldPos).xz);
			float simplePerlin2D712 = snoise( ( ( panner706 * 0.25 ) * WindTurbulenceFloat ) );
			float worldNoise1038 = simplePerlin2D712;
			float2 temp_cast_1 = (( worldNoise1038 * 2 )).xx;
			float simplePerlin2D797 = snoise( temp_cast_1 );
			float cos745 = cos( ( simplePerlin2D797 * GrassWiggleFloat * _WiggleStrenght ) );
			float sin745 = sin( ( simplePerlin2D797 * GrassWiggleFloat * _WiggleStrenght ) );
			float2 rotator745 = mul( i.uv_texcoord - float2( 0.5,0 ) , float2x2( cos745 , -sin745 , sin745 , cos745 )) + float2( 0.5,0 );
			#ifdef _WIGGLE_ON
				float2 staticSwitch1033 = rotator745;
			#else
				float2 staticSwitch1033 = i.uv_texcoord;
			#endif
			float4 tex2DNode97 = tex2D( _MainTex, staticSwitch1033 );
			o.Albedo = ( _Color * tex2DNode97 ).rgb;
			o.Alpha = 1;
			clip( tex2DNode97.a - _AlphaCutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=16700
7;77;1906;942;547.8752;-51.06168;3.473719;True;True
Node;AmplifyShaderEditor.CommentaryNode;1037;1367.12,1452.801;Float;False;1510.231;587.8159;World Noise;11;712;751;750;749;706;918;1019;714;1015;708;1018;;1,0,0.02020931,1;0;0
Node;AmplifyShaderEditor.Vector3Node;867;1057.914,1357.966;Float;False;Global;WindDirection;WindDirection;14;0;Create;True;0;0;False;0;0,0,0;-0.7071068,0,-0.7071068;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;1018;1417.681,1749.989;Float;False;FLOAT3;0;2;1;2;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;708;1427.754,1519.424;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;1015;1666.559,1750.773;Float;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;714;1623.195,1934.13;Float;False;Global;WindSpeedFloat;WindSpeedFloat;3;0;Create;True;0;0;False;0;2;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1019;1957.423,1890.921;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;918;1739.673,1516.475;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;706;2139.862,1524.508;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;750;2196.823,1844.52;Float;False;Global;WindTurbulenceFloat;WindTurbulenceFloat;4;0;Create;True;0;0;False;0;0.5;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;749;2344.651,1523.283;Float;False;0.25;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;751;2510.797,1526.13;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;712;2661.281,1523.776;Float;True;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1041;2058.232,2401.528;Float;False;806.2452;680.9117;Vertex Animation;8;754;857;755;1030;854;855;856;853;;0,1,0.8708036,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1038;2941.43,1527.926;Float;False;worldNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1039;1871.658,2708.265;Float;False;1038;worldNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1040;1641.561,812.3293;Float;False;1038;worldNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;853;2112.974,2490.024;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;856;2108.345,2900.443;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;1034;1872.214,747.3168;Float;False;1007.189;586.5881;UV Animation;7;745;799;746;798;797;1035;795;;0.7678117,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;854;2346.273,2578.697;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;993;2487.22,2076.615;Float;False;387.5991;274.1141;Strenght Noise;2;985;986;;1,0.6156863,0,1;0;0
Node;AmplifyShaderEditor.ScaleNode;795;1908.579,812.6546;Float;False;2;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;855;2351.035,2800.589;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1035;2025.109,1216.133;Float;False;Property;_WiggleStrenght;Wiggle Strenght;6;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;797;2095.125,806.8777;Float;True;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;798;2023.787,1052.705;Float;False;Global;GrassWiggleFloat;GrassWiggleFloat;4;0;Create;True;0;0;False;0;0.26;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;755;2344.516,2484.129;Float;False;Property;_WindStrenght;Wind Strenght;4;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;857;2531.034,2683.803;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1030;2337.359,2929.482;Float;False;Global;WindStrenghtFloat;WindStrenghtFloat;3;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;986;2501.715,2122.83;Float;False;1;0;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;746;2344.942,813.6662;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;985;2670.07,2123.101;Float;True;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;754;2701.919,2661.832;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;799;2439.094,1033.282;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1028;2980.049,2129.731;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;745;2617.415,902.978;Float;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;1033;3577.498,858.7823;Float;False;Property;_Wiggle;Wiggle;5;0;Create;True;0;0;False;0;1;1;1;True;_WIND_ON;Toggle;2;Key0;Key1;Create;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;872;3167.726,1367.195;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;292;3969.53,927.8489;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,1;0.3764702,0.470588,0.188235,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;97;3893.026,1123.991;Float;True;Property;_MainTex;MainTex;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;a73c218e0d8156240a793d22710686d1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToObjectTransfNode;1029;3341.557,1372.28;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1036;3904.731,807.437;Float;False;Property;_AlphaCutoff;Alpha Cutoff;1;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1031;3576.195,1345.762;Float;False;Property;_Wind;Wind;3;0;Create;True;0;0;False;0;1;1;1;True;_WIND_ON;Toggle;2;Key0;Key1;Create;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;4335.922,1060.561;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4525.362,1096.846;Float;False;True;2;Float;;0;0;Lambert;IL3DN/Grass;False;False;False;False;False;False;True;False;True;False;False;False;True;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;False;True;True;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;1036;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1018;0;867;0
WireConnection;1015;0;1018;0
WireConnection;1019;0;1015;0
WireConnection;1019;1;714;0
WireConnection;918;0;708;0
WireConnection;706;0;918;0
WireConnection;706;2;1019;0
WireConnection;749;0;706;0
WireConnection;751;0;749;0
WireConnection;751;1;750;0
WireConnection;712;0;751;0
WireConnection;1038;0;712;0
WireConnection;854;0;853;4
WireConnection;854;1;1039;0
WireConnection;795;0;1040;0
WireConnection;855;0;1039;0
WireConnection;855;1;856;2
WireConnection;797;0;795;0
WireConnection;857;0;854;0
WireConnection;857;1;855;0
WireConnection;985;0;986;0
WireConnection;754;0;755;0
WireConnection;754;1;857;0
WireConnection;754;2;1030;0
WireConnection;799;0;797;0
WireConnection;799;1;798;0
WireConnection;799;2;1035;0
WireConnection;1028;0;985;0
WireConnection;1028;1;754;0
WireConnection;745;0;746;0
WireConnection;745;2;799;0
WireConnection;1033;1;746;0
WireConnection;1033;0;745;0
WireConnection;872;0;867;0
WireConnection;872;1;1028;0
WireConnection;97;1;1033;0
WireConnection;1029;0;872;0
WireConnection;1031;0;1029;0
WireConnection;293;0;292;0
WireConnection;293;1;97;0
WireConnection;0;0;293;0
WireConnection;0;10;97;4
WireConnection;0;11;1031;0
ASEEND*/
//CHKSM=E1B5F1E9A9B21A6F84523B63925BB4A02236B450