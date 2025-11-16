#ifndef LAKU_UTIL_INC
#define LAKU_UTIL_INC

#ifndef PI
#define PI 3.1415926535897932
#endif
#define glsl_mod(x,y) (((x)-(y)*floor((x)/(y)))) 
float3 boxproject(float3 dir, float3 wpos) {
    UNITY_BRANCH
    if (length(unity_SpecCube0_ProbePosition) > 0.0) {
        float3 nrdir = normalize(dir);
        float3 rbmax = (unity_SpecCube0_BoxMax.xyz - wpos) / nrdir;
        float3 rbmin = (unity_SpecCube0_BoxMin.xyz - wpos) / nrdir;
        float3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;
        float fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);
        wpos -= unity_SpecCube0_ProbePosition.xyz;
        dir = wpos + nrdir * fa;
    }
    return dir;
}

float4 fresnel_laku(float3 normal, float4 wpos, float4 f0) {
    float3 n = normal;
    float3 v = normalize(_WorldSpaceCameraPos.xyz - wpos.xyz);
    float3 l = reflect(-v, normal);
    float3 h = normalize(l + v);
    float vdoth = dot(v, h);
    float4 f = f0 + (1-f0)*pow(1-vdoth,5);
    return f;
    float ndotv = dot(n, v);
}

float4 envmap(float3 reflection_dir, float roughness) {
    float4 env = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflection_dir, roughness*6);
    return float4(DecodeHDR(env, unity_SpecCube0_HDR),1);
}

float4 env_spec(float3 normal, float4 wpos, float4 color, float metallic, float roughness) {
    //return 0;
    float3 view_dir_w = normalize(_WorldSpaceCameraPos - wpos);
    float3 refl_dir_w = reflect(-view_dir_w, normal);
    float4 env = envmap(boxproject(refl_dir_w, wpos), roughness);
    float4 f0 = lerp(0.04, color, metallic);
    float4 f = fresnel_laku(normal, wpos, f0);
    float4 spec = env * f;
    // return max(0,spec); 
    // Did you know environment maps can have values above 1? I sure didn't!
    return saturate(spec);
}

float3 col_spec(float3 normal, float4 wpos, float3 color, float metallic) {
    //return 0;
    float3 view_dir_w = normalize(_WorldSpaceCameraPos - wpos);
    float3 f0 = lerp(0.04, color, metallic);
    float3 f = fresnel_laku(normal, wpos, float4(f0,1)).rgb;
    float3 spec = f * color;
    // return max(0,spec); 
    // Did you know environment maps can have values above 1? I sure didn't!
    return saturate(spec);
}

float sin01(float t) {return (sin(t)+1)*.5;}
float cos01(float t) {return (cos(t)+1)*.5;}
float atan2_01(float2 t) {return (atan2(t.x, t.y) + PI) / (PI * 2);}

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

float3 lab_to_lch(float3 c) {
    return float3(c.x, length(c.yz), any(c.yz) ? atan2(c.z, c.y) : 0);
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

float3 lch_to_lsrgb(float3 c) {
    return oklab_to_linear_srgb(lch_to_lab(c));
}

void ShadeSH9ToonDouble(float3 lightDirection, out float3 sh_max, out float3 sh_min, out float3 sh_dc) {
    float3 N = lightDirection;
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

void SH_Eval_01(float3 light_dir, float3 L0, float3 L1r, float3 L1g, float3 L1b, out float3 sh_max, out float3 sh_min, out float3 sh_dc) {
    float3 N = light_dir * 0.666666;
    float4 vB = N.xyzz * N.yzzx;
    sh_dc = L0;
    float3 l1;
    l1.r = dot(L1r, N);
    l1.g = dot(L1g, N);
    l1.b = dot(L1b, N);
    sh_max = L0 + l1;
    sh_min = L0 - l1;
}

float half_lambert(float f) {
    f = (0.5 * (f + 1));
    return f * f;
    return f;
}

float inv_lerp(float from, float to, float value){
    return (value - from) / (to - from);
}

#endif