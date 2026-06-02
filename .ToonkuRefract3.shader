Shader "Laku/ToonkuRefract3" {
    Properties {
@@insert .Toonku_Properties.shader@@
        [Header(Refract)]
		[Space]
        _RefractDistance("    Refract Distance", Float) = 0.1
        _RefractDarken("    Refract Darken", Float) = 0
        _RefractBlur("    Refract Blur", Float) = 0
		_GrabPassStrength("    GrabPass Strength", range(0,1)) = 1
		
@@insert .Toonku_Stencil.shader@@
		
@@insert .Toonku_Rendering_Opaque.shader@@
    }
    SubShader {
		Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
		//ZTest Always
		Cull [_Cull]
		GrabPass { "_ToonkuRefract3" }
        Pass {
			Tags { "LightMode" = "ForwardBase" }
			Blend [_BlendSrcBase] [_BlendDstBase], [_BlendSrcAlphaBase] [_BlendDstAlphaBase]
			BlendOp [_BlendOpBase], [_BlendOpAlpha]
			Stencil {
				Ref [_StencilRef]
				ReadMask [_StencilReadMask]
				WriteMask [_StencilWriteMask]
				Comp [_StencilComp]
				Pass [_StencilPass]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}
			ZWrite [_ZWrite]
			AlphaToMask [_AlphaToMask]
			
            HLSLPROGRAM
			#pragma target 5.0
            #pragma vertex vert
			// #define TOONKU_GEOMETRY
			#ifdef TOONKU_GEOMETRY
			#pragma geometry geom
			#endif
            #pragma fragment frag
			#pragma warning (disable : 4008)
			#define BASEPASS
			#define REFRACT
            static const uint REFRACT_PASS = 3;
			#include "Toonku.cginc"
            ENDHLSL
        }


		Pass {
			Tags { "LightMode"="ForwardAdd" }
			Blend [_BlendSrcAdd] [_BlendDstAdd], [_BlendSrcAlphaAdd] [_BlendDstAlphaAdd]
			BlendOp [_BlendOpAdd], [_BlendOpAlphaAdd]
			Stencil {
				Ref [_StencilRef]
				ReadMask [_StencilReadMask]
				WriteMask [_StencilWriteMask]
				Comp [_StencilComp]
				Pass [_StencilPass]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}
			ZWrite [_ZWrite]
			AlphaToMask [_AlphaToMask]
            
			HLSLPROGRAM
			#pragma target 5.0
            #pragma vertex vert
			// #define TOONKU_GEOMETRY
			#ifdef TOONKU_GEOMETRY
			#pragma geometry geom
			#endif
            #pragma fragment frag
			#pragma warning (disable : 4008)
			#define ADDPASS
			#define REFRACT
            static const uint REFRACT_PASS = 3;
			#pragma multi_compile_fragment POINT DIRECTIONAL SPOT POINT_COOKIE DIRECTIONAL_COOKIE
			#include "Toonku.cginc"
			ENDHLSL
		}

		Pass {
			Tags {"LightMode"="ShadowCaster"}

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			#include "ShadowCaster.cginc"
			ENDHLSL
		}
    }
}
