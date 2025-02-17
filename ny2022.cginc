#include "UnityCG.cginc"

float _DoSkirt, _DoEye;
float4 _SkirtUV, _EyeUV;

// the stinky who came up with this (me) should feel bad for what he did
// bytes are in reverse order inside the uints, so rows numbered 1-4 would be 0x04030201
// and the bits are mirrored left to right in the bytes : ) why did i do it like this 

static const uint font[36] = {
    0xc3e77e3c, 0xc3c3c3c3, 0x3c7ee7c3,  // [0] 0
    0xc3e77e3c, 0x3870e0c0, 0xffff0e1c,  // [1] 2
    0xc3c3c3c3, 0xc3ffffc3, 0xc3c3c3c3,  // [2] H
    0xc3e77e3c, 0xffffc3c3, 0xc3c3c3c3,  // [3] A
    0xc3e37f3f, 0x3f7fe3c3, 0x03030303,  // [4] P
    0xc3c3c3c3, 0x183c7ee7, 0x18181818,  // [5] Y
    0xcfcfc7c7, 0xfbdbdbdf, 0xe3e3f3f3,  // [6] N
    0x0303ffff, 0x033f3f03, 0xffff0303,  // [7] E
    0xc3c3c3c3, 0xffdbdbdb, 0x66667e7e,  // [8] W
    0xc3e37f3f, 0x3f7fe3c3, 0xc3c3e373,  // [9] R
    0x18181818, 0x18181818, 0x18180000,  // [10]!
    0x0303ffff, 0xc0e07f3f, 0x3c7ee7c3,  // [11]5
    // 0x7c787060, 0xff63676e, 0x606060ff,  // [11]4
    // 0x3e1e0e06, 0xffc6e676, 0x060606ff,  // [11]4
};

float map(float value, float min1, float max1, float min2, float max2) {
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float blit(float2 uv, uint idx) {
    if(any(uv < 0 || uv > 1)) return 0;
    uint2 iuv = int2(uv.x * 8, uv.y * 12);
    uint i = iuv.y / 4;
    uint shift = (iuv.y & 3) * 8 + iuv.x;
    float val = (font[i + idx * 3] >> shift) & 1;
    return val;
}
#define PI 3.1415926535897932384
#define R16 0.0625
#define R16R 0.015625
#define R17 0.05882352941176470588235294117647
#define R24 0.04166666666666666666666666666667
#define R24R 0.01041666666666666666666666666667
#define R25 0.04
#define R32 0.03125
#define R32R 0.0078125
#define R48 0.02083333333333333333333333333333
#define R48R 0.00520833333333333333333333333333

float to01(float f) { return (f + 1) * .5; }
float smoothblit(float2 uv, uint idx) {
    if (uv.x < -R16 || uv.x > (1+R16) || uv.y < -R24 || uv.y > (1+R24)) return 0;
    float val = blit(uv, idx) + 
                blit(uv + float2(R16, 0), idx) + 
                blit(uv - float2(R16, 0), idx) + 
                blit(uv + float2(0, R24), idx) + 
                blit(uv - float2(0, R24), idx);
    val *= .2;
    return val;
}

float3 smoothblit3(float2 uv, uint idx) {
    if (uv.x < -R16 || uv.x > (1+R16) || uv.y < -R24 || uv.y > (1+R24)) return 0;
    float val = blit(uv, idx) + 
                blit(uv + float2(R16, 0), idx) + 
                blit(uv - float2(R16, 0), idx) + 
                blit(uv + float2(0, R24), idx) + 
                blit(uv - float2(0, R24), idx);
    val *= .2;
    return float3(val,
        floor((uv.x + R16) * 16) * R25, 
        floor((uv.y + R24) * 24) * R25
    );
}

float3 year(float2 uv, float scale, float2 pos) {
    uv -= pos;
    uv *= scale;
    uv.x *= 1.5;
    float3 val = smoothblit3(uv - float2(R16,R24), 1);
    val += smoothblit3(uv - float2(R16 * 21,R24), 0);
    val += smoothblit3(uv - float2(R16 * 42,R24), 1);
    val += smoothblit3(uv - float2(R16 * 63,R24), 1);
    return val;
}

float2 uvbounce(float2 uv, float offset) {
    float x = (frac(_Time.y + offset)*2)-1;
    uv.y += 1-x*x;
    return uv;
}

float3 yearbounce(float3 uva, float scale, float2 pos) {
    float2 uv = uva.xy;
    pos.x = frac(pos.x);
    if(pos.x > .5 && uv.x < .5) uv.x += 1;
    uv -= pos;
    uv *= scale;
    uv.y += 1 + R24 * 2;
    uv.x *= 1.5;
    uv.x *= uva.z;
    float3 val = smoothblit3(uvbounce(uv - float2(R16,R24),0), 1);
    val += smoothblit3(uvbounce(uv - float2(R16 * 21,R24),-.2), 0);
    val += smoothblit3(uvbounce(uv - float2(R16 * 42,R24),-.4), 1);
    val += smoothblit3(uvbounce(uv - float2(R16 * 63,R24),-.6), 1);
    val.y += floor(floor((uv.x) * 16) / 20);
    return val;
}

float2 uvwave(float2 uv) {
    
    return uv;
}

float3 wavetext(float3 uva, float scale, float2 pos) {
    float2 uv = uva.xy;
    pos.x = frac(pos.x);
    if(pos.x > .5 && uv.x < .5) uv.x += 1;
    uv -= pos;
    uv *= scale;
    uv.y += 1 + R24 * 2;
    uv.y += sin(uv.x * 2 + _Time.y * 2) * .3;
    uv.x *= 1.5;
    uv.x *= uva.z;
    static const int text[15] = {2,3,4,4,5,-1,6,7,8,-1,5,7,3,9,10};
    float val = 0;
    // [unroll]
    for(int i = 0; i < 15; ++i) {
        if(text[i] > 0) {
            float2 uv0 = uv - float2(R16 * i * 21, R24);
            val += smoothblit(uvwave(uv0), text[i]);
        }
    }
    return float3(val,
        floor((uv.x + R16) * 16) * R25, 
        floor((uv.y + R24) * 24) * R25
    );
}

float3 wavetext2(float3 uva, float scale, float2 pos) {
    float2 uv = uva.xy;
    pos.x = frac(pos.x);
    if(pos.x > .5 && uv.x < .5) uv.x += 1;
    uv -= pos;
    uv *= scale;
    uv.y += 1 + R24 * 2;
    uv.y += sin(uv.x * 2 + _Time.y * 2) * .3;
    uv.x *= 1.5;
    uv.x *= uva.z;
    static const int text[15] = {2,3,4,4,5,-1,6,7,8,-1,5,7,3,9,10};
    float val = 0;
    // [unroll]
    for(int i = 0; i < 15; ++i) {
        if(text[i] > 0) {
            float2 uv0 = uv - float2(R16 * i * 21, R24);
            val += smoothblit(uvwave(uv0), text[i]);
        }
    }
    return float3(val,
        floor((uv.x + R16) * 16) * R25, 
        floor((uv.y + R24) * 24) * R25
    );
}

float3 year3(float2 uv, float scale, float2 pos) {
    uv -= pos;
    uv *= scale;
    uv.x *= 1.5;
    float val = smoothblit(uv - float2(R16,R24), 1);
    val += smoothblit(uv - float2(R16 * 21,R24), 0);
    val += smoothblit(uv - float2(R16 * 42,R24), 1);
    val += smoothblit(uv - float2(R16 * 63,R24), 1);
    return float3(val,
        floor((uv.x + R16) * 16) * R25, 
        floor((uv.y + R24) * 24) * R25
    );
}

float2 uvroty(float2 uv, float offset) {
    float pivot = .5;
    uv -= pivot;
    const float speed = 4;
    float f = sin(_Time.y * speed + offset);
    float f2 = (cos((_Time.y * speed + offset)));
    uv.x /= (f);
    uv.y *= 1 + f2*.2 * uv.x;
    uv += pivot;
    return uv;
}

float2 uvroty2(float2 uv, float offset) {
    return uv;
    float pivot = .5;
    uv -= pivot;
    const float speed = 4;
    float f = sin(_Time.y * speed + offset);
    float f2 = (cos((_Time.y * speed + offset)));
    uv.x /= (f);
    uv.y *= 1 + f2*.2 * uv.x;
    uv += pivot;
    return uv;
}

float2 uvroty3(float2 uv, float offset) {
    // return uv;
    float pivot = .5;
    uv -= pivot;
    const float speed = 5;
    float t = _Time.y * speed + offset;
    float f = sin(t);
    float f2 = cos(t);
    uv.x /= (f);
    uv.y *= 1 + f2*.2 * uv.x;
    uv += pivot;
    return uv;
}

float3 yearspin(float3 uva, float scale, float2 pos) {
    float2 uv = uva.xy;
    pos.x = frac(pos.x);
    if(pos.x > .5 && uv.x < .5) uv.x += 1;
    uv -= pos;
    uv *= scale;
    uv.x *= 1.5;
    uv.x *= uva.z;
    float3 val = smoothblit3(uvroty(uv - float2(R16,R24),0), 1);
    val += smoothblit3(uvroty(uv - float2(R16 * 21,R24),-.5), 0);
    val += smoothblit3(uvroty(uv - float2(R16 * 42,R24),-1.0), 1);
    val += smoothblit3(uvroty(uv - float2(R16 * 63,R24),-1.5), 1);
    return val;
}

float2 eyething(float2 uv) {
    // uv -= float2(.5,.5);
    // float a = atan2(uv.x, uv.y) * .5;
    // float b = length(uv);
    // uv.x = a;
    // uv.y = b;
    return uv;
}

float3 yeareye(float3 uva, float scale, float2 pos) {
    float2 uv = uva.xy;
    uv -= pos;
    uv *= scale;
    uv.x *= 1.5;
    uv.x *= uva.z;
    uv -= float2(2.8,2.5);
    float a = (atan2(uv.x, uv.y) + PI) / (PI * 2);
    a = a*16 + (_Time.y)*3;
    a = fmod(a,8);
    float b = length(uv) - .7;
    uv.x = a;
    uv.y = b;

    float3 val = smoothblit3(eyething(uv - float2(R16,R24)), 1);
    val += smoothblit3(eyething(uv - float2(R16 * 21,R24)), 0);
    val += smoothblit3(eyething(uv - float2(R16 * 42,R24)), 1);
    val += smoothblit3(eyething(uv - float2(R16 * 63,R24)), 1);
    return val;
}

float3 _hsv2rgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float3 _hsv2rgb(float a, float b, float c) {
    return _hsv2rgb(float3(a,b,c));
}

float4 vgrad0(float3 val) {
    float val1 = val.x > 0;
    float val2 = val.x > .2;
    val1 = lerp(val1, 0, val2);
    float vv = abs(val.z - .5);
    float v =  vv*vv*10;
    float3 c0 = _hsv2rgb(float3(to01(sin(_Time.x * 2)),1,1));
    float3 c1 = _hsv2rgb(float3(to01(sin(_Time.x * 2)),1,.04));
    val1 *= .2;
    float3 rgb = (val1 + val2) * lerp(c1,c0,v);
    return float4(rgb, val1 + val2);
}
float4 rainbow0(float3 val) {
    float val1 = val.x > .2;
    float val2 = val.x < .9;
    float3 rgb = (val1) * (_hsv2rgb(frac((val.y*2 + val.z + _Time.y*.8)*.5), 1, 1) + val2*.4);
    return float4(rgb, saturate(val1 + val2));
}

float4 plasmarim(float3 val) {
    float val1 = val.x > 0;
    val.yz *= .5;
    val.y -= 3;
    float3 rgb = (val1) * (_hsv2rgb(frac((val.y*sin(val.z*4+_Time.y) + val.z*cos(val.y*3+_Time.y*2) + _Time.y*.8)*.5), 1, 1-val.x));
    return float4(rgb, val1);
}

float4 plasmarim2(float3 val) {
    float val1 = val.x > 0;
    val.yz *= .5;
    val.y *= 5;
    val.y -= 3;
    float3 rgb = (val1) * (_hsv2rgb(
        frac((val.y*sin(val.z*4+_Time.y) + val.z*cos(val.y*3+_Time.y*2) + _Time.y*.8)*.5),
        1,
        1-val.x
    ));
    return float4(rgb, val1);
}

float4 bounce0(float3 val) {
    if(val.x == 0) return 0;
    float val1 = val.x > 0;
    float val2 = val.x > .2;
    val1 = lerp(val1, 0, val2);
    val1 *= 1;
    float idx = floor(val.y);
    val.y = (val.y - idx) * 1.5;
    float offset = idx * -.2;
    float x = floor(_Time.y + offset);
    float v = (pow(1 - abs(val.y - .5),7))*2;
    float v2 = (pow( abs(val.y - .5),2))*3;
    float hue = frac(x*1.7832);
    float3 c0 = _hsv2rgb(hue,1,1);
    float3 c1 = _hsv2rgb(hue,1,.04);
    float3 col0 = lerp(c1,c0,v);
    float3 col1 = lerp(c1,c0,v2);
    return float4(val1 * col1 + val2 * col0, val1 + val2);
}

float4 skirt(float3 uv) {
    float4 col = 0;
    col += bounce0(yearbounce(uv, 10, float2(-_Time.x*2, 1)));
    col += plasmarim(wavetext(uv, 12.5, float2(-_Time.x*1, .6)));
    col += vgrad0(yearspin(uv, 10, float2(-_Time.x*2 + .5,.25)));
    return col;
}

float4 eye(float3 uv) {
    float4 col = 0;
    col += rainbow0(yeareye(uv, 5, float2(0,0)));
    return col;
}

float4 do_skirt(ToonkuData i) {
    float umin = _SkirtUV.x;
    float umax = _SkirtUV.z;
    float vmin = _SkirtUV.y;
    float vmax = _SkirtUV.w;
    [branch] if(i.uv.x < umin || i.uv.x > umax || i.uv.y < vmin || i.uv.y > vmax) return 0;
    float aspect =  (umax - umin) / (vmax - vmin);
    float3 uv;
    uv.x = map(i.uv.x, umin, umax, 0, 1);
    uv.y = 1 - map(i.uv.y, vmin, vmax, 0, 1);
    uv.z = aspect;
    return skirt(uv);
}

float4 do_eye(ToonkuData i) {
    float umin = _EyeUV.x;
    float umax = _EyeUV.z;
    float vmin = _EyeUV.y;
    float vmax = _EyeUV.w;
    [branch] if(i.uv.x < umin || i.uv.x > umax || i.uv.y < vmin || i.uv.y > vmax) return 0;
    float aspect =  (umax - umin) / (vmax - vmin);
    float3 uv;
    uv.x = map(i.uv.x, umin, umax, 0, 1);
    uv.y = 1 - map(i.uv.y, vmin, vmax, 0, 1);
    uv.z = aspect;
    return eye(uv);
}

float3 yearspin2(float3 uva, float scale, float2 pos) {
    float2 uv = uva.xy;
    pos.x = frac(pos.x);
    if(pos.x > .5 && uv.x < .5) uv.x += 1;
    uv -= pos;
    uv *= scale;
    uv.x *= 1.5;
    uv.x *= uva.z;
    float3 val = smoothblit3(uvroty2(uv - float2(R16,R24),0), 1);
    val += smoothblit3(uvroty2(uv - float2(R16 * 21,R24),-.5), 0);
    val += smoothblit3(uvroty2(uv - float2(R16 * 42,R24),-1.0), 1);
    val += smoothblit3(uvroty2(uv - float2(R16 * 63,R24),-1.5), 11);
    return val;
}

float3 yearspin3(float3 uva, float scale, float2 pos) {
    float2 uv = uva.xy;
    pos.x = frac(pos.x);
    if(pos.x > .5 && uv.x < .5) uv.x += 1;
    uv -= pos;
    uv *= scale;
    uv.x *= 1.5;
    uv.x *= uva.z;
    float3 val = smoothblit3(uvroty3(uv - float2(R16,R24),0), 1);
    val += smoothblit3(uvroty3(uv - float2(R16 * 21,R24),-.5), 0);
    val += smoothblit3(uvroty3(uv - float2(R16 * 42,R24),-1.0), 1);
    val += smoothblit3(uvroty3(uv - float2(R16 * 63,R24),-1.5), 11);
    return val;
}

float3 do_collar(ToonkuData i) {
    float umin = 0.158631;
    float umax = 0.831852;
    float vmin = 0.96568;
    float vmax = 0.98687;
    i.uv = frac(i.uv);
    [branch] if(i.uv.x < umin || i.uv.x > umax || i.uv.y < vmin || i.uv.y > vmax) return 0;
    float aspect =  (umax - umin) / (vmax - vmin);
    float3 uv;
    uv.x = map(i.uv.x, umin, umax, 0, 1);
    uv.y = 1 - map(i.uv.y, vmin, vmax, 0, 1);
    uv.z = aspect / 4;
    uv.x = frac(uv.x * 4);
    // return (yearspin2(uv, 1, float2(-_Time.x*4+.5,0)));;
    return plasmarim2(yearspin2(uv, 1, float2(-_Time.x*4+.5,0)));;
}

float3 do_belt(ToonkuData i) {
    float umin = 0.544049;
    float umax = 0.991385;
    float vmin = 0.442866;
    float vmax = 0.473128;
    i.uv = frac(i.uv);
    [branch] if(i.uv.x < umin || i.uv.x > umax || i.uv.y < vmin || i.uv.y > vmax) return 0;
    float aspect =  (umax - umin) / (vmax - vmin);
    float3 uv;
    uv.x = map(i.uv.x, umin, umax, 0, 1);
    uv.y = 1 - map(i.uv.y, vmin, vmax, 0, 1);
    uv.z = aspect;
    // uv.x = frac(uv.x * 2);
    // return (yearspin2(uv, 1, float2(-_Time.x*4+.5,0)));;
    return vgrad0(wavetext(uv, 2, float2(_Time.x*4+.5,.7)));;
}

float3 do_sleeve(ToonkuData i, float umin, float umax, float vmin, float vmax) {
    i.uv = frac(i.uv);
    [branch] if(i.uv.x < umin || i.uv.x > umax || i.uv.y < vmin || i.uv.y > vmax) return 0;
    float aspect =  (umax - umin) / (vmax - vmin);
    float3 uv;
    uv.x = map(i.uv.x, umin, umax, 0, 1);
    uv.y = 1 - map(i.uv.y, vmin, vmax, 0, 1);
    uv.z = aspect;
    return vgrad0(yearspin3(uv, 1.5, float2(-_Time.x*4+.5,.1)));;
}

float3 do_the_thing(ToonkuData i) {
    float3 col = 0;
    col += do_collar(i);
    col += do_belt(i);
    col += do_sleeve(i, 0.800732, 0.987643, 0.70839, 0.740803);
    col += do_sleeve(i, 0.010698, 0.19761, 0.704114, 0.736527);
    
    return col;
}

float4 extra_func(ToonkuData i) {
    if(i.facing < 0) return 0;
    float4 col = 0;
    [branch] if(_DoSkirt) col += do_skirt(i);
    [branch] if(_DoEye) col += do_eye(i);
    return col;
}