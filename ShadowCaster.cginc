float _Toggle1;
float _Toggle2;

sampler2D _MainTex;
float _ShadowAlphaClip;

struct appdata_base_color {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 color : COLOR; // probably dont need this actually but its there for now
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
	V2F_SHADOW_CASTER;
    float3 uva : TEXCOORD;
};

v2f vert(appdata_base_color v) {
	v2f o;
	TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
	if(_Toggle1 && v.texcoord.x >= 1.0f && v.texcoord.x < 2.0f) { o.pos.z = -1; }
	if(_Toggle2 && v.texcoord.x >= 2.0f && v.texcoord.x < 3.0f) { o.pos.z = -1; }
    o.uva = float3(v.texcoord.xy, v.color.a);
	return o;
}

float4 frag(v2f i) : SV_Target {
    if(_ShadowAlphaClip < 1) clip(tex2D(_MainTex, i.uva.xy).a * i.uva.z - (1-_ShadowAlphaClip));
	SHADOW_CASTER_FRAGMENT(i)
}