Shader "Laku/ToonkuFireworks" {
    Properties {
@@insert .Toonku_Properties.shader@@
        
		[Header(Fireworks)]
		[Space]
		// [NoScaleOffset] _RandomDirTex("Random Dir Texture", 2D) = "white" {}
		
@@insert .Toonku_Rendering_Opaque.shader@@
    }
    SubShader {
		// Tags { "Queue" = "Geometry" }
		//ZTest Always
		Cull [_Cull]
        Pass {
			Tags { "LightMode" = "ForwardBase" }
			Blend [_BlendSrcBase] [_BlendDstBase], [_BlendSrcAlphaBase] [_BlendDstAlphaBase]
			BlendOp [_BlendOp], [_BlendOpAlpha]
            HLSLPROGRAM
			#pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
			#define BASEPASS
            #define TOONKU_FIREWORKS
			#include "ToonkuInclude.cginc"	
            #include "ny2022.cginc"
            #include "toonku_fireworks.cginc"
			#include "Toonku.cginc"	

            ENDHLSL
        }


		Pass {
			Tags { "LightMode"="ForwardAdd" }
			Blend [_BlendSrcAdd] [_BlendDstAdd], [_BlendSrcAlphaAdd] [_BlendDstAlphaAdd]
			BlendOp [_BlendOpAdd], [_BlendOpAlphaAdd]
			HLSLPROGRAM
			#pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
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
			ENDHLSL
		}
    }
}
