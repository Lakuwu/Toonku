#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Util.cginc"
#include "ToonkuInclude.cginc"

sampler2D _MainTex;
sampler2D _EmissionTex;
float _EmissionMul;
sampler2D _NormalTex;
float4 _MainTex_TexelSize;
sampler2D _MetalnessTex;
sampler2D _RoughnessTex;
sampler2D _EnvMapMaskTex;
sampler2D _HSVMaskTex;
sampler2D _GrabTexture;
float _Metalness;
float _MetalnessDiffuseMask;
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

// #ifdef XMASLIGHTS
float _WarmWhite, _GamerRGB;
// #endif

float _MinLight;
float _FinalBrightness;

#define TWO_PI 2 * PI

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
    o.tangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
    // o.tangent = normalize(o.tangent - dot(o.tangent, o.normal) * o.normal);
    o.bitangent = cross(o.normal, o.tangent) * v.tangent.w * unity_WorldTransformParams.w;
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

float4 xmaslight(v2fa v) {
    float idx = floor(v.uv);
    float3 lch;
    uint mode = 0;
    if(_WarmWhite) mode = 1;
    if(_GamerRGB) mode = 2;
    [forcecase]
    switch(mode) {
        case 0: {
            // traditional
            idx = idx % 4;
            float3 colors[4] = {
                {1, .5, .8},
                {.7, .5, 2.7},
                {1, .6, 1.9},
                {.5, .5, 3.9}
            };
            lch = colors[idx];
            break;
        }
        case 1: {
            // warm white
            lch = float3(1.5, .2, 1.3);
            break;
        }
        case 2: {
            // gamer rgb
            const float num_lights = 81;
            float r = idx / num_lights;
            float f = TWO_PI * (r * 2 + _Time.y * .5);
            lch = float3(1.5,.7, f);
            break;
        }
    }
    return float4(lch_to_lsrgb(lch), 1);
    // float4 col = 1;
    // float f = (TWO_PI / num_colors) * idx;
    // float f = (TWO_PI / num_colors) * idx + floor((r * num_colors) + _Time.y * .5);
    // float f = floor(frac(r * 2) + _Time.y * .3);
    // float f = floor(_Time.y*5 + idx * 0.01);
    // float t = floor(_Time.y);
    // float t = (_Time.x);
    // float t = 0;
    // float3 lch = float3(1.1,.5, f + t);
    // col = float4(idx % 2, 0, 0, 1);
    // col.rgb = lch_to_lsrgb(lch);
    // return col;
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
    v2fa ret = vert_process(v);
#ifdef XMASLIGHTS
    ret.color = xmaslight(ret);
#endif
    return ret;
}

#endif

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
    
    #ifdef TOONKU_OVERRIDE_MAINTEX
        return override_maintex(i, tex2D(_MainTex, i.uv));
    #else
        return tex2D(_MainTex, i.uv);
    #endif
    
    #endif
}

float3 specular(ToonkuData i) {
    return 1;
}

float3 shading_diff_spec(ToonkuData i, float diffuse, float fresnel_light_mask, out float3 diff, out float3 spec) {
    float3 albedo_col = i.color.rgb;
    float diffuse_shade = smoothstep(_DiffShadeStart, _DiffShadeEnd, diffuse);
    float3 diffuse_col = albedo_col * lerp(_DiffShadeColor, float3(1,1,1), diffuse_shade) * (1-i.metalness * _MetalnessDiffuseMask);
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
    diff = diffuse_col * fresnel_shade_col;
    spec = _FresnelLightAmount * fresnel_light_col;
    return col;
}

float3 shading(ToonkuData i, float diffuse, float fresnel_light_mask) {
    float3 diff, spec;
    return shading_diff_spec(i, diffuse, fresnel_light_mask, diff, spec);
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

half4 frag (v2fa input, half facing : VFACE) : SV_Target {
    ToonkuData i;
    i.pos = input.pos;
    i.uv = input.uv;
    i.wpos = input.wpos;
    i.facing = facing;
    i.onormal = normalize(input.onormal);
    i.opos = input.opos;
    i.vertex_color = input.color;
    // normal mapping :)
    float3 tex_normal = UnpackNormal(tex2D(_NormalTex, i.uv));
    i.normal.x = dot(float3(input.tangent.x, input.bitangent.x, input.normal.x), tex_normal);
    i.normal.y = dot(float3(input.tangent.y, input.bitangent.y, input.normal.y), tex_normal);
    i.normal.z = dot(float3(input.tangent.z, input.bitangent.z, input.normal.z), tex_normal);
    i.normal = i.normal * facing;
    i.normal = normalize(i.normal);
    i.view_dir = normalize(_WorldSpaceCameraPos - i.wpos.xyz);
    i.fresnel = dot(i.normal, i.view_dir);
    i.color = lerp(half4(1,1,1,1), sample_maintex(i), _TexInfluence) * _Color;
    i.vnormal = normalize(input.vnormal);
    float metalness = tex2D(_MetalnessTex, i.uv) * _Metalness;
    i.metalness = metalness;
    float2 screen_uv = input.screenpos.xy / input.screenpos.w;
#ifdef XMASLIGHTS
    float3 grab = tex2D(_GrabTexture, screen_uv - i.vnormal.xy*0.01*i.pos.z);
    // col.rgb += grab * input.color;
    // return float4(saturate(grab-1), 1);
    i.color.rgb = lerp(grab * input.color, input.color, 0.02) + saturate(grab-1)*100;
#endif
    // return i.pos.z;
    // return i.color;
    // return float4(i.vnormal, 1);
    
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
    float3 diff = 0, spec = 0;
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
    float3 diff_ambient = 0, spec_ambient = 0;
    float3 col_ambient = shading_diff_spec(i, diffuse_ambient, fresnel_light_mask, diff_ambient, spec_ambient);
    col_ambient = color_adjust(i, saturate(col_ambient), input.hue);
    col_ambient *= max(saturate(ambient_col), _MinLight.xxx);
    col_ambient = lerp(0, col_ambient, _UseSH);
    
    diff_ambient = color_adjust(i, saturate(diff_ambient), input.hue);
    diff_ambient *= max(saturate(ambient_col), _MinLight.xxx);
    diff_ambient = lerp(0, diff_ambient, _UseSH);
    
    spec_ambient = color_adjust(i, saturate(spec_ambient), input.hue);
    spec_ambient *= max(saturate(ambient_col), _MinLight.xxx);
    spec_ambient = lerp(0, spec_ambient, _UseSH);
    
    float3 diff_wl = 0, spec_wl = 0;
    float3 col_wl = shading_diff_spec(i, diffuse_wl, fresnel_light_mask, diff_wl, spec_wl);
    col_wl = color_adjust(i, saturate(col_wl), input.hue);
    col_wl *= max(saturate(_LightColor0 * attenuation), _MinLight.xxx);
    col_wl = lerp(0, col_wl, _UseRealtimeLights);
    
    diff_wl = color_adjust(i, saturate(diff_wl), input.hue);
    diff_wl *= max(saturate(_LightColor0 * attenuation), _MinLight.xxx);
    diff_wl = lerp(0, diff_wl, _UseRealtimeLights);
    spec_wl = color_adjust(i, saturate(spec_wl), input.hue);

    spec_wl *= max(saturate(_LightColor0 * attenuation), _MinLight.xxx);
    spec_wl = lerp(0, spec_wl, _UseRealtimeLights);
    
    diff = max(diff_ambient, diff_wl);
    spec = max(spec_ambient, spec_wl);
    
    col.rgb = max(col_ambient, col_wl);

    
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
    
    
    float roughness = tex2D(_RoughnessTex, i.uv) * _Roughness;
    float envmapmul = tex2D(_EnvMapMaskTex, i.uv) * _EnvMapMask;
    spec += envmapmul * env_spec(i.normal, i.wpos, i.color, metalness, roughness) * lerp(float4(1.0.xxxx), i.vertex_color, _MultiplySpecularByVertexCol);
    // float3 pt = input.tangent;
    // col.rgb = float3(-pt.x,-pt.z,pt.y); // blender tangents?
#ifdef ALPHA
    col.rgb = saturate(diff) + saturate(spec);
    col.a = saturate(i.color.a + luminance(spec));
    // col.rgb = lerp(saturate(spec), saturate(diff) + saturate(spec), i.color.a);
    // col.a = saturate(i.color.a + max_component(spec));
    // col.a = lerp(i.color.a, 1, luminance(spec));
    // col.a = i.color.a;
#else
    // col.rgb = max(diff,0) + max(spec,0);
    // col.rgb = saturate(diff) + saturate(spec);
    col.a = i.color.a;
#endif
    
#ifdef ADDPASS
    col.rgb *= col.a;
#endif
    col.rgb += tex2D(_EmissionTex, i.uv) * _EmissionMul;
    col.rgb *= _FinalBrightness;

    float3 dithering = (ditherNoiseFuncHigh(screen_uv) - 0.5) * 2 * 0.002;
    col.rgb = max(col.rgb + dithering, float3(0,0,0));
    return col;
}
