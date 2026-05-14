Shader "Laku/Toonku" {
    Properties {
@@insert .Toonku_Properties.shader@@
        
@@insert .Toonku_Stencil.shader@@
		
@@insert .Toonku_Rendering_Opaque.shader@@
    }
    SubShader {
		Tags { "RenderType" = "Opaque" }
		//ZTest Always
		Cull [_Cull]
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
