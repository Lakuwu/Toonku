Shader "Laku/ToonkuSnow" {
    Properties {
@@insert .Toonku_Properties.shader@@
		
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
        
@@insert .Toonku_Rendering_Opaque.shader@@
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
