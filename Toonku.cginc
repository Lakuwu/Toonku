#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Util.cginc"
#include "ToonkuInclude.cginc"

sampler2D _MainTex;
float4 _MainTex_TexelSize;
sampler2D _MetalnessTex;
sampler2D _RoughnessTex;
sampler2D _EnvMapMaskTex;
sampler2D _HSVMaskTex;
float _Metalness;
float _Roughness;
float _EnvMapMask;
float _AlphaClip;
float _SHLightColorDir;
float _TexInfluence;
float _SpecExp;
float _SpecMul;
float _SpecSmooth;
half4 _Color;
half4 _DiffShadeColor;
float _DiffShadeStart;
float _DiffShadeEnd;
half4 _FresnelShadeColor;
float _FresnelShadeStart;
float _FresnelShadeEnd;
half4 _FresnelLightColor;
float _FresnelLightStart;
float _FresnelLightEnd;
float _FresnelLightRingStart;
float _FresnelLightRingEnd;
float _FresnelLightRingMode;
float _FresnelLightRingMul;
float _FresnelLightAmount;
sampler2D _FresnelLightMaskTex;
float _FresnelLightTint;
float _AnimIdx;
float _LightnessMul;
float _UseHSV;
float _ChromaMul;
float _MultiplySpecularByVertexCol;
float _HueShift, _HueShift1, _HueShift2, _HueShift3, _HueShift4, _HueShift5, _HueShift6, _HueShift7;
float _HueShiftAnim, _HueShiftAnim1, _HueShiftAnim2, _HueShiftAnim3, _HueShiftAnim4, _HueShiftAnim5, _HueShiftAnim6, _HueShiftAnim7;
float _HueShiftFresnel, _HueShiftFresnel1, _HueShiftFresnel2, _HueShiftFresnel3, _HueShiftFresnel4, _HueShiftFresnel5, _HueShiftFresnel6, _HueShiftFresnel7;
float4 _LightColor0;
float _SHDirectionalColor;
float _Toggle1;
float _Toggle2;
float _Debug;
float _LightingOverride;
float _UseSH, _UseRealtimeLights;
float _GeomAngle;

float _MinLight;
float _FinalBrightness;

float4 permute(float4 x){return glsl_mod(((x*34.0)+1.0)*x, 289.0);}
float4 taylorInvSqrt(float4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise3(float3 v){ 
    const float2  C = float2(1.0/6.0, 1.0/3.0) ;
    const float4  D = float4(0.0, 0.5, 1.0, 2.0);

    // First corner
    float3 i  = floor(v + dot(v, C.yyy) );
    float3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 i1 = min( g.xyz, l.zxy );
    float3 i2 = max( g.xyz, l.zxy );
  
    // x0 = x0 - 0. + 0.0 * C 
    float3 x1 = x0 - i1 + 1.0 * C.xxx;
    float3 x2 = x0 - i2 + 2.0 * C.xxx;
    float3 x3 = x0 - 1. + 3.0 * C.xxx;
  
    // Permutations
    i = glsl_mod(i, 289.0 ); 
    float4 p = permute( permute( permute( 
               i.z + float4(0.0, i1.z, i2.z, 1.0 ))
             + i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
             + i.x + float4(0.0, i1.x, i2.x, 1.0 ));
  
    // Gradients
    // ( N*N points uniformly over a square, mapped onto an octahedron.)
    float n_ = 1.0/7.0; // N=7
    float3  ns = n_ * D.wyz - D.xzx;
  
    float4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)
  
    float4 x_ = floor(j * ns.z);
    float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
  
    float4 x = x_ *ns.x + ns.yyyy;
    float4 y = y_ *ns.x + ns.yyyy;
    float4 h = 1.0 - abs(x) - abs(y);
  
    float4 b0 = float4( x.xy, y.xy );
    float4 b1 = float4( x.zw, y.zw );
  
    float4 s0 = floor(b0)*2.0 + 1.0;
    float4 s1 = floor(b1)*2.0 + 1.0;
    float4 sh = -step(h, 0.f.xxxx);
  
    float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
  
    float3 p0 = float3(a0.xy,h.x);
    float3 p1 = float3(a0.zw,h.y);
    float3 p2 = float3(a1.xy,h.z);
    float3 p3 = float3(a1.zw,h.w);
  
    // Normalise gradients
    float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
  
    // Mix final noise value
    float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}

float rand1(float n){return frac(sin(n) * 43758.5453123);}

float4 angle_axis(float a, float3 v) {
    float half_a = a * .5f;
    float c = cos(half_a);
    float s = sin(half_a);
    return float4(v.x * s, v.y * s, v.z * s, c);
}

float4 hamilton_product(float4 a, float4 b) {
    return float4(
        a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
        a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
        a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
        a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
    );
}

float3 rotate(float3 v, float4 q) {
    float4 p = float4(v.x, v.y, v.z, 0);
    float4 q_dot = float4(-q.x, -q.y, -q.z, q.w);
    float4 qp = hamilton_product(q, p);
    float4 r = hamilton_product(qp, q_dot);
    return float3(r.x, r.y, r.z);
}

v2fa vert_process(appdata v) {
    v2fa o;
    o.pos = UnityObjectToClipPos(v.pos);
    o.wpos = mul(unity_ObjectToWorld, v.pos);
    o.opos = v.pos;
    o.uv = v.uv;
    o.color = v.color;
    o.screenpos = ComputeScreenPos(o.pos);
    o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
    o.onormal = v.normal;
    // o.viewdir = normalize(WorldSpaceViewDir(v.pos));
    #ifdef TOONKU_FIREWORKS
    o.camera_pos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
    o.random = noise3(float2(floor(time()),123.456));
    o.random1 = noise3(float2(floor(time2()),789.123));
    o.random2 = noise3(float2(floor(time3()),567.891));
    #endif
    o.vnormal = any(v.normal) ? COMPUTE_VIEW_NORMAL : 0; // fix division by zero error(?)
    if(_Toggle1 && v.uv.x >= 1.0f && v.uv.x < 2.0f) { o.pos.z = -1; }
    if(_Toggle2 && v.uv.x >= 2.0f && v.uv.x < 3.0f) { o.pos.z = -1; }
    
    [forcecase] switch(_AnimIdx) {
        case 1.0f:
            o.hue.x = _HueShift1;
            o.hue.y = _HueShiftAnim1;
            o.hue.z = _HueShiftFresnel1;
            break;
        case 2.0f:
            o.hue.x = _HueShift2;
            o.hue.y = _HueShiftAnim2;
            o.hue.z = _HueShiftFresnel2;
            break;
        case 3.0f:
            o.hue.x = _HueShift3;
            o.hue.y = _HueShiftAnim3;
            o.hue.z = _HueShiftFresnel3;
            break;
        case 4.0f:
            o.hue.x = _HueShift4;
            o.hue.y = _HueShiftAnim4;
            o.hue.z = _HueShiftFresnel4;
            break;
        case 5.0f:
            o.hue.x = _HueShift5;
            o.hue.y = _HueShiftAnim5;
            o.hue.z = _HueShiftFresnel5;
            break;
        case 6.0f:
            o.hue.x = _HueShift6;
            o.hue.y = _HueShiftAnim6;
            o.hue.z = _HueShiftFresnel6;
            break;
        case 7.0f:
            o.hue.x = _HueShift7;
            o.hue.y = _HueShiftAnim7;
            o.hue.z = _HueShiftFresnel7;
            break;
        default:
            o.hue.x = _HueShift;
            o.hue.y = _HueShiftAnim;
            o.hue.z = _HueShiftFresnel;
            break;
    }
    return o;
}

#ifdef TOONKU_GEOMETRY

appdata vert(appdata v) {
    return v;
}

[maxvertexcount(6)]
void geom(triangle appdata v[3], inout TriangleStream<v2fa> output) {
    v2fa o[3] = {vert_process(v[0]),vert_process(v[1]),vert_process(v[2])};
    output.Append(o[0]);
    output.Append(o[1]);
    output.Append(o[2]);
    output.RestartStrip();
    float angle = (_GeomAngle) * 2 * PI;
    float scale = 1;
    float4 q = angle_axis(angle, float3(0,1,0));
    // return;
    [unroll]
    for(int i = 0; i < 3; ++i) {
        v[i].pos.xyz = rotate(v[i].pos.xyz * scale, q);
        v[i].normal = rotate(v[i].normal, q);
        v[i].pos.z += 1; 
        output.Append(vert_process(v[i]));
    }
    output.RestartStrip();
}

#else

v2fa vert(appdata v) {
    // v.pos.xyz = v.pos.xyz + snoise3(v.pos.xyz + _Time.y * 60) * v.normal * .01;
    // float t = _Time.y;
    // float s = .05;
    // v.pos.x += (rand1(v.pos.x + t)*2-1) * s * pow(sin01(v.pos.y * 32 + t * 8),10);
    // v.pos.z += (rand1(v.pos.z + t)*2-1) * s * pow(sin01(v.pos.y * 32 + t * 8),10);
    // v.pos.y += (rand1(v.pos.y + t)*2-1) * s * pow(sin01(v.pos.y * 32 + t * 8),10);
    
    // float4 q2 = angle_axis(sin(_Time.x * 10) * v.pos.y * 2, float3(0,0,1));
    // float4 q = angle_axis(_Time.x * 10 - length(v.pos.xz) * 2 + sin(_Time.x * 10) * v.pos.y * 5, float3(0,1,0));
    // float4 qq = hamilton_product(q, q2);
    // float4 q0 = angle_axis(_Time.x * 10, float3(0,1,0));
    // float4 q1 = angle_axis(_Time.x * 10, float3(1,0,0));
    // float4 qq = hamilton_product(q1, q0);
    // v.pos.xyz = rotate(v.pos.xyz, qq);
    // v.normal = rotate(v.normal, qq);
    
    return vert_process(v);
}

#endif

#define MOD3 float3(443.8975,397.2973, 491.1871)

float ditherNoiseFuncLow(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * MOD3 + _Time.y);
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.x + p3.y) * p3.z);
}

float3 ditherNoiseFuncHigh(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * (MOD3 + _Time.y));
    p3 += dot(p3, p3.yxz + 19.19);
    return frac(float3((p3.x + p3.y)*p3.z, (p3.x + p3.z)*p3.y, (p3.y + p3.z)*p3.x));
}

// Inigo Quilez my beloved <3
// https://www.shadertoy.com/view/XsfGDn
// https://iquilezles.org/articles/texture/

float4 textureNice(sampler2D tex, float4 texelsize, float2 uv) {
    uv = uv * texelsize.zw + 0.5;
    float2 iuv = floor(uv);
    float2 fuv = frac(uv);
    uv = iuv + fuv*fuv*(3.0-2.0*fuv);
    uv = (uv - 0.5) * texelsize.xy;
    return tex2D(tex, uv);
}

float3 permute(float3 x) { return glsl_mod(((x*34.0)+1.0)*x, 289.0); }
float snoise(float2 v){
  const float4 C = float4(0.211324865405187, 0.366025403784439,
           -0.577350269189626, 0.024390243902439);
  float2 i  = floor(v + dot(v, C.yy) );
  float2 x0 = v -   i + dot(i, C.xx);
  float2 i1;
  i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  float4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = glsl_mod(i, 289.0);
  float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 ))
  + i.x + float3(0.0, i1.x, 1.0 ));
  float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  float3 x = 2.0 * frac(p * C.www) - 1.0;
  float3 h = abs(x) - 0.5;
  float3 ox = floor(x + 0.5);
  float3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  float3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

float sdf_magic(float d) {
    float fd = length(float2(ddx(d),ddy(d)));
    return d / max(fd, .0001);
}

float robe_sample(float f) {
    float f0 = frac(f);
    float d0 = f0 - .5;
    float f1 = frac(f + .5);
    float d1 = f1 - .5;
    float e0 = -sdf_magic(d0);
    float e1 = sdf_magic(d1);
    e0 = saturate(e0);
    e1 = saturate(e1);
    float v0 = lerp(e0, e1, f0 > .75 || f0 < .25);
    return v0;
}

float robe_f0(float2 uv, float t) {
    float f = snoise(uv * 6 + t.xx) * .3
            + snoise(uv * 2 + t.xx) * .7;
    return f;
}

float robe_f1(float2 uv, float t) {
    float f = snoise(uv * 1 + t.xx + 3) * .3
            + snoise(uv * 2 + t.xx + 3) * .7;
    return f;
}

float robepattern(ToonkuData i) {
    float3 col;
    float t0 = _Time.x * .05 + 3;
    float t1 = -_Time.x * .03 + 3;
    
    float2 uvdx = float2(ddx(i.uv.x), ddy(i.uv.x)) * .25;
    float2 uvdy = float2(ddx(i.uv.y), ddy(i.uv.y)) * .25;
    
    float v0 = robe_sample(robe_f0(i.uv - uvdx - uvdy, t0) * 14);
    v0 +=      robe_sample(robe_f0(i.uv + uvdx - uvdy, t0) * 14);
    v0 +=      robe_sample(robe_f0(i.uv - uvdx + uvdy, t0) * 14);
    v0 +=      robe_sample(robe_f0(i.uv + uvdx + uvdy, t0) * 14);
    v0 *= .25;

    float n = 6;
    float v1 = robe_sample(robe_f1(i.uv - uvdx - uvdy, t1) * n);
    v1 +=      robe_sample(robe_f1(i.uv + uvdx - uvdy, t1) * n);
    v1 +=      robe_sample(robe_f1(i.uv - uvdx + uvdy, t1) * n);
    v1 +=      robe_sample(robe_f1(i.uv + uvdx + uvdy, t1) * n);
    v1 *= .25;
    float v = (v0 + v1) * .5;
    return v;
    // col = v;
    // return float4(col * .025 + .01, 1);
}

float4 sample_maintex(ToonkuData i) {
    #ifdef TOONKU_EXTRA
        float4 extra_col = extra_func(i);
        float4 main_col = tex2D(_MainTex, i.uv);
        // float4 main_col = textureNice(_MainTex, _MainTex_TexelSize, i.uv);
        // return 1;
        if(extra_col.a < 0) {
            return float4(main_col.rgb * extra_col.rgb, main_col.a);
        }
        return float4(lerp(main_col.rgb, extra_col.rgb, extra_col.a), main_col.a);
    #else
        return tex2D(_MainTex, i.uv);
        // return textureNice(_MainTex, _MainTex_TexelSize, i.uv);
    #endif
}

float3 shading(ToonkuData i, float diffuse, float fresnel_light_mask) {
    float3 albedo_col = i.color.rgb;
    float diffuse_shade = smoothstep(_DiffShadeStart, _DiffShadeEnd, diffuse);
    float3 diffuse_col = albedo_col * lerp(_DiffShadeColor, float3(1,1,1), diffuse_shade);
    float fresnel_shade = smoothstep(_FresnelShadeStart, _FresnelShadeEnd, i.fresnel);
    float3 fresnel_shade_col = lerp(_FresnelShadeColor, float3(1,1,1), fresnel_shade);
    float fresnel_light_ring = smoothstep(_FresnelLightRingStart, _FresnelLightRingEnd, i.fresnel);
    fresnel_light_ring = 1 - (fresnel_light_ring * _FresnelLightRingMul);
    float fresnel_light = smoothstep(_FresnelLightStart, _FresnelLightEnd, i.fresnel);
    fresnel_light = lerp(
        fresnel_light * fresnel_light_ring,
        fresnel_light + fresnel_light_ring,
        _FresnelLightRingMode);
    float3 fresnel_light_col = lerp(_FresnelLightColor, float3(0,0,0), fresnel_light);
    fresnel_light_col *= lerp(float3(1,1,1), i.vertex_color, _MultiplySpecularByVertexCol);
    fresnel_light_col = lerp(fresnel_light_col, fresnel_light_col * albedo_col, _FresnelLightTint);
    fresnel_light_col *= fresnel_light_mask;
    float3 col = diffuse_col * fresnel_shade_col + (_FresnelLightAmount * fresnel_light_col);
    return col;
}

float3 ObjectToWorldPos(float3 LocalPos) {
    return mul( unity_ObjectToWorld, float4( LocalPos, 1 ) ).xyz;
}

float max_component(float3 v) {
    return max(v.x, max(v.y, v.z));
}

float3 scale_to_01(float3 v) {
    float m = max_component(v);
    return m == 0 ? float3(0,0,0) : v/m;
}

float luminance(float3 v) {
    return 0.2126 * v.r + 0.7152 * v.g + 0.0722 * v.b;
}

float3 rgb2hsv(float3 c) {
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 hsv2rgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float3 hsv_adjust(ToonkuData i, float3 col, float3 hue) {
    float hue_shift = hue.x, hue_shift_anim = hue.y, hue_shift_fresnel = hue.z;
    
    float3 col_hsv = rgb2hsv(col.rgb);
    col_hsv.y = pow(col_hsv.y, lerp(.75, 1, col_hsv.z * col_hsv.z));
    col_hsv.x += lerp(hue_shift * !hue_shift_fresnel, hue_shift * _Time.x, hue_shift_anim);
    col_hsv.x += lerp(0, hue_shift * i.fresnel, hue_shift_fresnel);
    col_hsv.x = frac(col_hsv.x);
    col_hsv.z *= _LightnessMul;
    col_hsv.y *= _ChromaMul;
    col.rgb = hsv2rgb(col_hsv);
    return col;
}

float3 lab_to_lch(float3 c) {
    return float3(c.x, length(c.yz), atan2(c.z, c.y));
}

float3 lch_to_lab(float3 c) {
    return float3(c.x, c.y * cos(c.z), c.y * sin(c.z));
}

#define ONE_THIRD 1.0/3.0
float3 linear_srgb_to_oklab(float3 c) {
    float l = 0.4122214708f * c.r + 0.5363325363f * c.g + 0.0514459929f * c.b;
	float m = 0.2119034982f * c.r + 0.6806995451f * c.g + 0.1073969566f * c.b;
	float s = 0.0883024619f * c.r + 0.2817188376f * c.g + 0.6299787005f * c.b;
    
    float l_ = pow(l, ONE_THIRD);
    float m_ = pow(m, ONE_THIRD);
    float s_ = pow(s, ONE_THIRD);
    
    return float3(
        0.2104542553f * l_ + 0.7936177850f * m_ - 0.0040720468f * s_,
        1.9779984951f * l_ - 2.4285922050f * m_ + 0.4505937099f * s_,
        0.0259040371f * l_ + 0.7827717662f * m_ - 0.8086757660f * s_
    );
}

float3 oklab_to_linear_srgb(float3 c) {
    float l_ = c.x + 0.3963377774f * c.y + 0.2158037573f * c.z;
    float m_ = c.x - 0.1055613458f * c.y - 0.0638541728f * c.z;
    float s_ = c.x - 0.0894841775f * c.y - 1.2914855480f * c.z;

    float l = l_*l_*l_;
    float m = m_*m_*m_;
    float s = s_*s_*s_;

    return float3(
		+4.0767416621f * l - 3.3077115913f * m + 0.2309699292f * s,
		-1.2684380046f * l + 2.6097574011f * m - 0.3413193965f * s,
		-0.0041960863f * l - 0.7034186147f * m + 1.7076147010f * s
    );
}

#define TWO_PI 2 * PI
float3 oklab_adjust(ToonkuData i, float3 col, float3 hue) {
    float hue_shift = hue.x * TWO_PI, hue_shift_anim = hue.y, hue_shift_fresnel = hue.z;
    
    float3 lab = linear_srgb_to_oklab(col.rgb);
    float3 lch = lab_to_lch(lab);
    
    #ifdef TOONKU_FIREWORKS
    float theta = atan2_01(i.vnormal.xy) * TWO_PI;
    float angle_hue = theta * 2 + _Time.y;
    #endif
    
    lch.z += lerp(hue_shift * !hue_shift_fresnel, hue_shift * _Time.x, hue_shift_anim);
    lch.z += lerp(0, hue_shift * i.fresnel, hue_shift_fresnel);
    
    #ifdef TOONKU_FIREWORKS
    lch.z += angle_hue;
    #endif
    
    lch.z = glsl_mod(lch.z, TWO_PI);
    lch.x = (lch.x * _LightnessMul);
    lch.y = (lch.y * _ChromaMul);
    
    lab = lch_to_lab(lch);
    col.rgb = oklab_to_linear_srgb(lab);
    return col;
}

// float3 color_adjust(ToonkuData i, float3 col, float3 hue) {
//     [branch] if(hue.x == 0) return col;
    
//     [branch] if(_UseHSV * tex2D(_HSVMaskTex, i.uv).x)
//         return hsv_adjust(i, col, hue);
//     else
//         return oklab_adjust(i, col, hue);
// }

float3 color_adjust(ToonkuData i, float3 col, float3 hue) {
    float3 ret = col;
    [branch] if(hue.x || _ChromaMul != 1.0f || _LightnessMul != 1.0f) {
        [branch] if(_UseHSV * tex2D(_HSVMaskTex, i.uv).x)
            ret = hsv_adjust(i, col, hue);
        else
            ret = oklab_adjust(i, col, hue);
    }
    return ret;
}





float tv_static(ToonkuData i) {
    float lines_per_unit = 120;
    float line_n = trunc(i.wpos.y * lines_per_unit - .5);
    // return frac(i.pos.x * 1000);
    // return line_n % 2;  
    // float t = 0;
    float t = trunc(_Time.y * 60) / 60;
    // float t = trunc(_Time.y * 60) / 60;
    // return frac(_Time.y);
    float a = snoise3(float3(i.wpos.x + line_n, i.wpos.z + line_n, t) * 60);
    a = pow((a+1)*.5,2);
    // return pow((a+1)*.5,2);
    // float angle = atan2(i.opos.x, i.opos.z);
    // return snoise(float2(angle + line_n, 0) * 10);
    float b = pow(abs(frac(i.wpos.y * lines_per_unit) - .5) * 2, .4 + (1-a) * .5) * a;
    return b;
}

void ShadeSH9ToonDouble(float3 lightDirection, out float3 sh_max, out float3 sh_min, out float3 sh_dc) {
    float3 N = lightDirection * 0.666666;
    float4 vB = N.xyzz * N.yzzx;
    // L0 L2
    float3 res = float3(unity_SHAr.w,unity_SHAg.w,unity_SHAb.w);
    sh_dc = res;
    res.r += dot(unity_SHBr, vB);
    res.g += dot(unity_SHBg, vB);
    res.b += dot(unity_SHBb, vB);
    res += unity_SHC.rgb * (N.x * N.x - N.y * N.y);
    // L1
    float3 l1;
    l1.r = dot(unity_SHAr.rgb, N);
    l1.g = dot(unity_SHAg.rgb, N);
    l1.b = dot(unity_SHAb.rgb, N);
    sh_max = res + l1;
    sh_min = res - l1;
}

float half_lambert(float f) {
    f = (0.5 * (f + 1));
    return f * f;
    return f;
}

float inv_lerp(float from, float to, float value){
    return (value - from) / (to - from);
}

half4 frag (v2fa input, half facing : VFACE) : SV_Target {
    ToonkuData i;
    i.pos = input.pos;
    i.uv = input.uv;
    i.wpos = input.wpos;
    i.normal = input.normal * facing;
    i.facing = facing;
    i.onormal = normalize(input.onormal);
    i.opos = input.opos;
    i.vertex_color = input.color;
    // TODO: normal mapping
    i.normal = normalize(i.normal);
    i.view_dir = normalize(_WorldSpaceCameraPos - i.wpos.xyz);
    i.fresnel = dot(i.normal, i.view_dir);
    i.color = lerp(half4(1,1,1,1), sample_maintex(i), _TexInfluence) * _Color;
    // return i.color;
    i.vnormal = normalize(input.vnormal);
    // #ifdef TOONKU_FIREWORKS
    // float3 funny = input.vnormal;
    // funny.z = 0;
    // return atan2_01(i.vnormal.xy);
    // return 
    // return float4(funny, 1);
    // #endif
    
    float4 wl = _WorldSpaceLightPos0;
    float attenuation = 1;
    if(wl.w == 1) {
        // Point/Spot light
        float4 dirtolight = wl - i.wpos;
        UNITY_LIGHT_ATTENUATION(point_attenuation, 0, i.wpos.xyz);
        attenuation = point_attenuation;
        wl = float4(normalize(dirtolight.xyz),0);
    } else {
        // Directional light
        wl = float4(normalize(wl.xyz), 0);
    }
    
    float lightcolor0_lum = saturate(luminance(_LightColor0));
    float wl_ndotl = dot(i.normal, (float3)wl);
    float diffuse_wl = half_lambert(wl_ndotl) * lightcolor0_lum;
    // float diffuse_wl = (wl_ndotl) * lightcolor0_lum;
    
    
    float fresnel_light_mask = tex2D(_FresnelLightMaskTex, i.uv);
#ifdef TOONKU_ROBEPATTERN
    float robe_val = robepattern(i);
    i.color = float4(robe_val.xxx * .03 + .01, 1);
    float mask = 1 - abs((robe_val * 2) - 1);
    mask += saturate((robe_val * 2 - 1)) * .0;
    fresnel_light_mask *= mask;
    // fresnel_light_mask *= saturate((robe_val * 2) - 1); 
    // fresnel_light_mask *= robe_val;
#endif

    float4 col = 1;
#ifdef BASEPASS
    // https://github.com/lilxyzw/lilToon/blob/31c6e3936d0571207935a4395c3374e25b82c009/Assets/lilToon/Shader/Includes/openlit_core.hlsl#L65C8-L65C8
    // SH magic from OpenLit / LilToon:
    float3 sh9Dir = unity_SHAr.xyz * 0.333333 + unity_SHAg.xyz * 0.333333 + unity_SHAb.xyz * 0.333333;
    float3 lightDirectionForSH9 = dot(sh9Dir,sh9Dir) < 0.000001 ? 0 : normalize(sh9Dir);
    float3 sh_min, sh_max, sh_dc;
    ShadeSH9ToonDouble(lightDirectionForSH9, sh_max, sh_min, sh_dc);
    
    float3 ambient_dir = max(0,ShadeSH9(float4(i.normal, 1)));
    // return float4(sh_dc, 1);
    
    float3 lab_sh_dc = linear_srgb_to_oklab(sh_dc);
    float3 lab_shmax = linear_srgb_to_oklab(sh_max);
    float3 ambient_col = 0;
    [branch] if(_SHDirectionalColor) {
        float3 lab_ambient_dir = linear_srgb_to_oklab(ambient_dir);
        // blend dark colors towards sh_dc to prevent uglyness
        // float dark = smoothstep(0,1,saturate((lab_ambient_dir.x - .10) * 5));
        float dark = saturate((lab_ambient_dir.x - .2) * 3);
        // return float4(dark.xxx, 1);
        lab_ambient_dir.yz = lerp(lab_sh_dc.yz, lab_ambient_dir.yz, dark);
        // lab_ambient_dir.yz *= smoothstep(0,1,saturate((lab_ambient_dir.x - .05) * 10));
        lab_ambient_dir.x = lab_shmax.x;
        ambient_col = oklab_to_linear_srgb(lab_ambient_dir);
    } else {
        lab_sh_dc.x = lab_shmax.x;
        ambient_col = oklab_to_linear_srgb(lab_sh_dc);
    }
    // return float4(ambient_col, 1);
    
    float diffuse_ambient = inv_lerp(luminance(sh_min), luminance(sh_max), luminance(ambient_dir));
    diffuse_ambient = saturate(diffuse_ambient); // fix weird lines :)
    diffuse_ambient *= diffuse_ambient;
    // return float4(diffuse_ambient.xxx,1);
    // diffuse_ambient = half_lambert(dot(i.normal, lightDirectionForSH9));
    // return diffuse_ambient;
    if(diffuse_ambient != diffuse_ambient) {
        diffuse_ambient = 0;
    }
    
    // float diff = diffuse_ambient + diffuse_wl;
    // col.rgb = shading(i, diff);
    // col.rgb = color_adjust(i, saturate(col.rgb), input.hue);
    // float3 lighting_rgb = saturate(ambient_col + _LightColor0 * attenuation);
    // col.rgb *= lighting_rgb;
    float3 col_ambient = shading(i, diffuse_ambient, fresnel_light_mask);
    col_ambient = color_adjust(i, saturate(col_ambient), input.hue);
    col_ambient *= max(saturate(ambient_col), _MinLight.xxx);
    col_ambient = lerp(0, col_ambient, _UseSH);
    float3 col_wl = shading(i, diffuse_wl, fresnel_light_mask);
    col_wl = color_adjust(i, saturate(col_wl), input.hue);
    col_wl *= max(saturate(_LightColor0 * attenuation), _MinLight.xxx);
    col_wl = lerp(0, col_wl, _UseRealtimeLights);
    col.rgb = max(col_ambient, col_wl);
    // return float4(col.rgb, 1);
    
    // float3 col_lab = linear_srgb_to_oklab(col);
    // float3 lighting_lab = linear_srgb_to_oklab(lighting_rgb);
    // col_lab.x *= lighting_lab.x;
    // lighting_lab.x = 1;
    // lighting_rgb = oklab_to_linear_srgb(lighting_lab);
    // float3 col_rgb = oklab_to_linear_srgb(col_lab) * lighting_rgb;
    // col.rgb = lerp(col_rgb, col.rgb, 1);
    #ifdef TOONKU_FIREWORKS
    col.rgb = max(col.rgb, do_fireworks(input));
    col.rgb = max(col.rgb, do_the_thing(i));
    // return float4(do_the_thing(i), 1);
    // return float4(year(input.uv, 4, float2(0,0)),1);
    #endif
#endif
    
#ifdef ADDPASS
    col.rgb = shading(i, diffuse_wl, fresnel_light_mask);
    col.rgb = color_adjust(i, col, input.hue);
    col.rgb *= max(saturate(_LightColor0 * attenuation), _MinLight.xxx);
#endif
    
    float metalness = tex2D(_MetalnessTex, i.uv) * _Metalness;
    float roughness = tex2D(_RoughnessTex, i.uv) * _Roughness;
    float envmapmul = tex2D(_EnvMapMaskTex, i.uv) * _EnvMapMask;
    col += envmapmul * env_spec(i.normal, i.wpos, i.color, metalness, roughness) * lerp(float4(1.0.xxxx), i.vertex_color, _MultiplySpecularByVertexCol);
    col.a = i.color.a;
    
#ifdef ADDPASS
    col.rgb *= col.a;
#endif

    col.rgb *= _FinalBrightness;

    float2 screen_uv = input.screenpos.xy / input.screenpos.w;
    float3 dithering = (ditherNoiseFuncHigh(screen_uv) - 0.5) * 2 * 0.002;
    col.rgb = max(col.rgb + dithering, float3(0,0,0));
    return col;
}