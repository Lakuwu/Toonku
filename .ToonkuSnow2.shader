Shader "Laku/ToonkuSnow2" {
    Properties {
@@insert .Toonku_Properties.shader@@
		
		[Header(Snow)]
		[Space]
        _SnowTex ("Snow SDF Texture Array", 2DArray) = "white" {}
        _SDFThreshold("SDF Threshold", range(-.1,.1)) = 0
		[NoScaleOffset] _SnowMaskTex("Snow Mask", 2D) = "white" {}
		_SnowUV("Snow UV", Vector) = (0, 0, 1, 1)
		_SnowAlpha("Snow Alpha", Range(0,1)) = 1
		_SnowScale("Snow Scale", Range(0,10)) = 1
		[IntRange] _SnowAmount("Snow Amount", Range(0,200)) = 1
		_SnowSpeed("Snow Speed", Range(-10,10)) = 1
		_SnowXMul("Snow X Mul", Range(1, 8)) = 1
        
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
            #pragma fragment frag
			#define BASEPASS
			#define TOONKU_OVERRIDE_MAINTEX
			#include "ToonkuInclude.cginc"
			#include "Snow2.cginc"
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
            #pragma fragment frag
			#define ADDPASS
			#pragma multi_compile_fragment POINT DIRECTIONAL SPOT POINT_COOKIE DIRECTIONAL_COOKIE
			#define TOONKU_OVERRIDE_MAINTEX
			#include "ToonkuInclude.cginc"
			#include "Snow2.cginc"
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
