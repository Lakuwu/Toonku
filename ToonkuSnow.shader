Shader "Laku/ToonkuSnow" {
    Properties {
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcBase("Base Blend Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstBase("Base Blend Dst", Float) = 0
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpBase("Base Blend Op", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcAlphaBase("Base Blend Alpha Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstAlphaBase("Base Blend Alpha Dst", Float) = 10
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpAlphaBase("Base Blend Alpha Op", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcAdd("Add Blend Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstAdd("Add Blend Dst", Float) = 1
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpAdd("Add Blend Op", Float) = 4
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcAlphaAdd("Add Blend Alpha Src", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstAlphaAdd("Add Blend Alpha Dst", Float) = 1
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpAlphaAdd("Add Blend Alpha Op", Float) = 4
		
		[Space]
		_Color("Color", Color) = (1, 1, 1, 1)
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		_Metalness("Metalness", range(0,1)) = 0
		[NoScaleOffset] _MetalnessTex("Metalness Texture", 2D) = "white" {}
		_Roughness("Roughness", range(0,1)) = 0.5
		[NoScaleOffset] _RoughnessTex("Roughness Texture", 2D) = "white" {}
		_EnvMapMask("Environment Mapping", range(0,1)) = 0
		[NoScaleOffset] _EnvMapMaskTex("Environment Mapping Mask", 2D) = "white" {}
		_AlphaClip("Alpha clip", range(0,1)) = 0.5
		_TexInfluence("Texture influence", range(0,1)) = 1
		
		[Header(Toon shading values)]
		[Space]
		_DiffShadeColor("Diffuse shade color", Color) = (1,1,1,1)
		_DiffShadeStart("Diffuse shade start", range(-1,1)) = 0.0
		_DiffShadeEnd("Diffuse shade end", range(-1,1)) = 0.5
		
		[Space]
		_FresnelShadeColor("Fresnel shade color", Color) = (1,1,1,1)
		_FresnelShadeStart("Fresnel shade start", range(0,1)) = 0.3
		_FresnelShadeEnd("Fresnel shade end", range(0,1)) = 0.5
		
		[Space]
		_FresnelLightAmount("Fresnel light amount", range(0,2)) = 0.1
		_FresnelLightColor("Fresnel light color", Color) = (1,1,1,1)
		_FresnelLightStart("Fresnel light start", range(0,1)) = 0.3
		_FresnelLightEnd("Fresnel light end", range(0,1)) = 0.5
		_FresnelLightTint("Fresnel light tint", range(0,1)) = 0
		
		[Space]
		_FresnelLightRingStart("Fresnel light ring start", range(0,1)) = 1
		_FresnelLightRingEnd("Fresnel light ring end", range(0,1)) = 1
		_FresnelLightRingMul("Fresnel light ring mul", range(-1,1)) = 1
		[ToggleUI] _FresnelLightRingMode ("Fresnel light ring mode", Float) = 0
		
		[Header(Color Adjustment)]
		[Space]
		_LightnessMul("Lightness/Value Multiplier", Range(0, 2)) = 1
		_ChromaMul("Chroma/Saturation Multiplier", Range(0, 2)) = 1
		_HueShift("Hue Shift", Range(-1,1)) = 0
		[ToggleUI] _HueShiftAnim ("Animate Hue Shift", Float) = 0
		[ToggleUI] _HueShiftFresnel ("Fresnel Hue Shift", Float) = 0
		[ToggleUI] _UseHSV("Use HSV instead of OKLAB", Float) = 0
		[NoScaleOffset] _HSVMaskTex("HSV Mask", 2D) = "white" {}
		
		[Header(Misc)]
		[Space]
		[IntRange] _AnimIdx("Anim Idx", range(0, 7)) = 0
		[ToggleUI] _Debug("Debug Toggle", Float) = 0
		[ToggleUI] _MultiplySpecularByVertexCol("Multiply specular by vertex color", Float) = 0
		
		[Header(Lighting)]
		[Space]
		_LightingOverride("Lighting Override", range(0,1)) = 0
		[ToggleUI] _UseSH("Use Spherical Harmonics", Float) = 1
		[ToggleUI] _UseRealtimeLights("Use Realtime Lights", Float) = 1
		[ToggleUI] _SHDirectionalColor("Spherical Harmonics directional color", Float) = 0
		
		[HideInInspector] _HueShift1("",Float) = 0
		[HideInInspector] _HueShift2("",Float) = 0
		[HideInInspector] _HueShift3("",Float) = 0
		[HideInInspector] _HueShift4("",Float) = 0
		[HideInInspector] _HueShift5("",Float) = 0
		[HideInInspector] _HueShift6("",Float) = 0
		[HideInInspector] _HueShift7("",Float) = 0
		[HideInInspector] _HueShiftAnim1 ("", Float) = 0
		[HideInInspector] _HueShiftAnim2 ("", Float) = 0
		[HideInInspector] _HueShiftAnim3 ("", Float) = 0
		[HideInInspector] _HueShiftAnim4 ("", Float) = 0
		[HideInInspector] _HueShiftAnim5 ("", Float) = 0
		[HideInInspector] _HueShiftAnim6 ("", Float) = 0
		[HideInInspector] _HueShiftAnim7 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel1 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel2 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel3 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel4 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel5 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel6 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel7 ("", Float) = 0
		
		[Header(Toggles)]
		[Space]
        [ToggleUI] _Toggle1 ("Hide UV X 1-2", Float) = 0
        [ToggleUI] _Toggle2 ("Hide UV X 2-3", Float) = 0
		
		[Header(Snow)]
		[Space]
		[NoScaleOffset] _SnowMaskTex("Snow Mask", 2D) = "white" {}
		_SnowUV("Snow UV", Vector) = (0, 0, 1, 1)
		_SnowAlpha("Snow Alpha", Range(0,1)) = 1
		_SnowScale("Snow Scale", Range(0,10)) = 1
		[IntRange] _SnowAmount("Snow Amount", Range(0,200)) = 1
		_SnowSpeed("Snow Speed", Range(-10,10)) = 1
		[IntRange] _SnowXMul("Snow X Mul", Range(1, 8)) = 1
		[Space]
		_CandyUV("Candy UV", Vector) = (0, 0, 1, 1)
		_CandyColor0("Candy Color 0", Color) = (1, 1, 1, 1)
		_CandyColor1("Candy Color 1", Color) = (1, 1, 1, 1)
		_CandyColor2("Candy Color 2", Color) = (1, 1, 1, 1)
		_CandyXMul("Candy XMul", float) = 0
		_CandyYMul("Candy YMul", float) = 0
    }
    SubShader {
		// Tags { "Queue" = "Geometry" }
		//ZTest Always
		Cull [_Cull]
        Pass {
			Tags { "LightMode" = "ForwardBase" }
			Blend [_BlendSrcBase] [_BlendDstBase]
            CGPROGRAM
			#pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
			#define BASEPASS
			#define TOONKU_EXTRA
			
			#include "ToonkuInclude.cginc"	
			#include "snowflake.cginc"
			#include "Toonku.cginc"	
            ENDCG
        }


		Pass {
			Tags { "LightMode"="ForwardAdd" }
			Blend [_BlendSrcAdd] [_BlendDstAdd]
			BlendOp [_BlendOpAdd]
			CGPROGRAM
			#pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
			#define ADDPASS
			#pragma multi_compile_fragment POINT DIRECTIONAL SPOT POINT_COOKIE DIRECTIONAL_COOKIE
			#define TOONKU_EXTRA
			// float4 extra_func();
			#include "ToonkuInclude.cginc"
			#include "snowflake.cginc"
			#include "Toonku.cginc"
			ENDCG
		}

		Pass {
			Tags {"LightMode"="ShadowCaster"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v) {
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f i) : SV_Target {
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
    }
}
