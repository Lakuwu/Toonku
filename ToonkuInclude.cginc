#ifndef TOONKU_INCLUDE

#define TOONKU_INCLUDE
struct appdata {
    float4 pos : POSITION;
    float4 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 color : COLOR0;
};

struct ToonkuData {
    float4 pos;
    float2 uv;
    float4 wpos;
    float3 normal;
    float facing;
    float3 onormal;
    float4 opos;
    float4 vertex_color;
    float4 color;
    float fresnel;
    float3 view_dir;
    float3 vnormal;
    // float4 uv2 : TEXCOORD1;
    // float3 normal2 : NORMAL1;
    // float3 viewdir : TEXCOORD1;
};

struct v2fa {
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 wpos : TEXCOORD1;
    float3 normal : NORMAL;
    float3 onormal : TEXCOORD2;
    float4 opos : TEXCOORD3;
    float3 hue : TEXCOORD4;
    float4 color : COLOR0;
    float4 screenpos : TEXCOORD5;
    #ifdef TOONKU_FIREWORKS
    float3 camera_pos : TEXCOORD6;
    float3 random : TEXCOORD7;
    float3 random1 : TEXCOORD8;
    float3 random2 : TEXCOORD9;
    #endif
    float3 vnormal : TEXCOORD10;
    // float facing : VFACE;
    // float3 viewdir : TEXCOORD1;
    // float3 normal2 : NORMAL1;
};
#endif