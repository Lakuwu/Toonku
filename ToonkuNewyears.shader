Shader "Laku/ToonkuNewYears" {
    Properties {
		[Enum(One, 1, SrcAlpha, 5)] _BlendSrcBase("Base Blend Src", Float) = 1
		[Enum(Zero, 0, OneMinusSrcAlpha, 10)] _BlendDstBase("Base Blend Dst", Float) = 0
		[Enum(One, 1, DstAlpha, 7)] _BlendSrcAdd("Add Blend Src", Float) = 1
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
		_DiffShadeStart("Diffuse shade start", range(0,1)) = 0.0
		_DiffShadeEnd("Diffuse shade end", range(0,1)) = 0.5
		_FresnelShadeColor("Fresnel shade color", Color) = (1,1,1,1)
		_FresnelShadeStart("Fresnel shade start", range(0,1)) = 0.3
		_FresnelShadeEnd("Fresnel shade end", range(0,1)) = 0.5
		_FresnelLightColor("Fresnel light color", Color) = (1,1,1,1)
		_FresnelLightStart("Fresnel light start", range(0,1)) = 0.3
		_FresnelLightEnd("Fresnel light end", range(0,1)) = 0.5
		_FresnelLightAmount("Fresnel light amount", range(0,1)) = 0.1
		[Space]
		[ToggleUI] _DoSkirt("Do Skirt", float) = 0
		_SkirtUV("Skirt UV", Vector) = (0, 0, 1, 1)
		[Space]
		[ToggleUI] _DoEye("Do Eye", float) = 0
		_EyeUV("Eye UV", Vector) = (0, 0, 1, 1)
    }
    SubShader {
		// Tags { "Queue" = "Geometry" }
		//ZTest Always
		Cull Off
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
			#include "ny2022.cginc"
			#include "Toonku.cginc"	
            ENDCG
        }


		Pass {
			Tags { "LightMode"="ForwardAdd" }
			Blend [_BlendSrcAdd] One
			CGPROGRAM
			#pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
			#define ADDPASS
			#pragma multi_compile_fragment POINT DIRECTIONAL SPOT POINT_COOKIE DIRECTIONAL_COOKIE
			#define TOONKU_EXTRA
			#include "ToonkuInclude.cginc"
			#include "ny2022.cginc"
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
