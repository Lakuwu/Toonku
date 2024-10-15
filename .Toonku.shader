Shader "Laku/Toonku" {
    Properties {
@@insert .Toonku_Properties.shader@@
        
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
			ZWrite [_ZWrite]
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
			ZWrite [_ZWrite]
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

			float _Toggle1;
            float _Toggle2;

			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v) {
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				if(_Toggle1 && v.texcoord.x >= 1.0f && v.texcoord.x < 2.0f) { o.pos.z = -1; }
                if(_Toggle2 && v.texcoord.x >= 2.0f && v.texcoord.x < 3.0f) { o.pos.z = -1; }
				return o;
			}

			float4 frag(v2f i) : SV_Target {
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDHLSL
		}
    }
}
