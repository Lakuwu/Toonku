#define PI 3.1415926535897932384
#define PI_6 0.52359877559829887307710723054658

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Util.cginc"

UNITY_DECLARE_TEX2DARRAY(_SnowTex);
float _SnowSpeed;
float _SnowAmount;
sampler2D _SnowMaskTex;
float4 _SnowUV;
float _SnowAlpha;
float _SnowScale;
float _SnowXMul;
float _SDFThreshold;

float4 flake(float2 uv) {
    float2 p = uv;
    float r0 = atan2(p.x, p.y) / PI;
    r0 = (r0+1)*3;
    float r = abs(frac(r0) - .5) * (PI / 3);
    float c_hex = sqrt(0.75) / cos(r);
    float c = length(p);
    float hexagon = c <= c_hex;
    if(!hexagon) return 0;
    float a = cos(r) * c;
    float b = sin(r) * c;
    float bb = tan(PI_6) * a;
    float bh = (bb - b) * .5;
    float cc = bh / sin(PI_6);
    float bbbh = (bb + b) * .5;
    float ccc = bbbh / sin(PI_6);
    return float4(cc, ccc, a, hexagon) * hexagon;
}

float rand2(float x, float y) {
    float r = dot((float2(x, y)), float2(36.12345, 15.40956));
    r = frac(sin(r) * 3216.15683);
    return r;
}
float rand(float x) {
    return rand2(x, 9345.2312853);
}

float snowify(float3 p, float s) {
    p.z *= 1.15;
    float r =  rand(s);
    float hex = p.z < (1.0/floor(lerp(3,15,r)));
    float fingers = p.x < (1.0/floor(lerp(32,64, r)));
    float length = p.z < (10.0/floor(lerp(10,14, r)));
    float xx = 1 - (p.x * lerp(1.5,3, r));
    // return xx;
    // return fingers + hex;
    float detail = floor(lerp(20,30, r));
    float a = rand2(floor(p.x * detail) , s) * xx;
    float b = rand2(floor(p.y * detail) , s);
    float c = rand2(floor(p.z * detail) , s);
    // float ret = (a + b + c + (fingers + hex) * length) > 1.5;
    float ret = (a * b * c + (fingers + hex) * length) > .1;
    return ret;
    return floor(p.x * 16) % 2;
    return floor(p.z * 16) % 2;
    return floor(p.y*16) % 2;
}

float2 rotate(float2 p, float r) {
    return float2(p.x * cos(r) - p.y * sin(r), p.x * sin(r) + p.y * cos(r));
}

float sdf_threshold(float d) {
    // float fd = length(float2(ddx_fine(d),ddy_fine(d)));
    float fd = length(float2(ddx(d),ddy(d)));
    return d / max(fd, .0001);
}

float unpack(float f) {
    return (f * 255 - 127) / 255;
}

float sample_sdf(float3 uv) {
    float f = UNITY_SAMPLE_TEX2DARRAY(_SnowTex, uv);
    f = unpack(f)*4;
    float2 dd = float2(ddx(f), ddy(f)) * 2;
    float thres = _SDFThreshold;
    float a = saturate(sdf_threshold(thres - f));
    // return a;
    float b = pow(saturate(1-f), 6);
    return saturate(a + b * 1.0);
}

float multisample_sdf_frame(float2 uv, float frame) {
    uv = abs(uv);
    float2 uvdx = float2(ddx(uv.x), ddy(uv.x)) * .25;
    float2 uvdy = float2(ddx(uv.y), ddy(uv.y)) * .25;
    float a = sample_sdf(float3(uv - uvdx - uvdy, frame));
    a +=      sample_sdf(float3(uv + uvdx - uvdy, frame));
    a +=      sample_sdf(float3(uv - uvdx + uvdy, frame));
    a +=      sample_sdf(float3(uv + uvdx + uvdy, frame));
    a *= .25;
    return a;
}

float sample_sdf_frame(float2 uv, float frame) {
    uv = abs(uv);
    float a = sample_sdf(float3(uv, frame));
    return a;
}

float3 snowflake(float3 uva, int i, float t) {
    // t=0;
    float2 uv = uva.xy;
    uv.x = frac(uv.x * _SnowXMul);
    // float2 spos = (float2(i * 21.23, i * 125.643));
    t += floor(frac(i * 21.23) * _SnowXMul);
    float xspeed = sin(i + 42.956) * .8;
    float yspeed = (1 + abs(sin(i * 156.3242))) * 2;
    float y = yspeed * t + i * 125.643;
    float2 pos = float2(frac(xspeed * t + i * 21.23), frac(y));
    float scale = 100 + sin(i * 235.782 + y)* 40;
    scale *= _SnowScale;
    float2 poss = ((pos * 2) - 1) * (1 + (2 / scale));
    pos.y = ((poss + 1) * .5).y;
    if(uv.x > 0.8 && pos.x < 0.2) uv.x -= 1;
    if(uv.x < 0.2 && pos.x > 0.8) uv.x += 1;
    // if(pos.x > 0) return 1;
    float2 fpos = (pos - uv) * scale;
    fpos.x *= uva.z;
    // [branch] if(length(fpos) > 1) return 0;
    float rot = sin(y + i * 43) * 2;
    // rot = 0;
    float2 uv2 = rotate(fpos, rot);
    [branch] if(length(uv2) > 1) return 0;
    // return 1;
    // [branch] if(length(fpos > 1)) return 0;
    float4 f = flake(rotate(fpos, rot));
    // return uv2.x;
    float seed = floor(y + i * 37);
    float a = multisample_sdf_frame(uv2, seed % 256);
    float3 ret = float3(a, f.w,0);
    // return float3(uv2,0);
    return a.xxx;
    return ret;
    // return multisample_sdf_frame(fpos, 0);
    return f.w;
    float s = snowify(f.xyz, seed) * f.w;
    return s;
}

float3 snowflakes(float3 uv) {
    float3 val = 0;
    int num_flakes = _SnowAmount;
    // const int num_flakes = 25;
    float t = _Time.x * _SnowSpeed;
    
    [unroll(50)] // need to unroll otherwise compiler complains about gradient instructions
    for(int i = 0; i < num_flakes; ++i) {
        val += snowflake(uv, i, t);
        // [branch] if(val>0) return 1;
        // if(i >= num_flakes) return val > 0;
    }
    // float ret = val > 0;
    float3 ret = val;
    // ret = (ret / (1 - fwidth(ret)));
    // float w = fwidth(ret);
    // ret = smoothstep(-w, w, ret);
    return ret;
}

float map(float value, float min1, float max1, float min2, float max2) {
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float4 do_snowflake(ToonkuData i) {
    float3 uv;
    float umin = _SnowUV.x;
    float umax = _SnowUV.z;
    float vmin = _SnowUV.y;
    float vmax = _SnowUV.w;
    i.uv = frac(i.uv);
    float aspect =  (umax - umin) / ((vmax - vmin) * _SnowXMul);
    [branch] if(i.uv.x < umin || i.uv.x > umax || i.uv.y < vmin || i.uv.y > vmax) return 0;
    uv.x = map(i.uv.x, umin, umax, 0, 1);
    uv.y = map(i.uv.y, vmin, vmax, 0, 1);
    uv.z = aspect;
    float mask = tex2D(_SnowMaskTex, i.uv).r;
    if(mask < .5) return 0;
    float4 col = snowflakes(float3(uv.x, 1 - uv.y, uv.z)).xyzx * mask;
    col.a *= _SnowAlpha;
    // col.a = 1;
    return col;
}

float4 extra_func(ToonkuData i) {
    if(i.facing < 0) return 0;
    float4 col = do_snowflake(i);
    return col;
}

float4 override_maintex(ToonkuData i, float4 main_col) {
    [branch] if(i.facing < 0) return main_col;
    float4 col = do_snowflake(i);
    return float4(lerp(main_col.rgb, main_col.rgb + 1.0.xxx, col.a), main_col.a);
}