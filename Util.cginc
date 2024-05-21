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

half4 fresnel_laku(float3 normal, float4 wpos, half4 f0) {
    float3 n = normal;
    float3 v = normalize(_WorldSpaceCameraPos.xyz - wpos.xyz);
    float3 l = reflect(-v, normal);
    float3 h = normalize(l + v);
    float vdoth = dot(v, h);
    half4 f = f0 + (1-f0)*pow(1-vdoth,5);
    return f;
    float ndotv = dot(n, v);
}

half4 envmap(float3 reflection_dir, float roughness) {
    float4 env = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflection_dir, roughness*6);
    return half4(DecodeHDR(env, unity_SpecCube0_HDR),1);
}

half4 env_spec(float3 normal, float4 wpos, float4 color, float metallic, float roughness) {
    //return 0;
    float3 view_dir_w = normalize(_WorldSpaceCameraPos - wpos);
    float3 refl_dir_w = reflect(-view_dir_w, normal);
    half4 env = envmap(boxproject(refl_dir_w, wpos), roughness);
    half4 f0 = lerp(0.04, color, metallic);
    half4 f = fresnel_laku(normal, wpos, f0);
    half4 spec = env * f;
    return max(0,spec);
}

float sin01(float t) {return (sin(t)+1)*.5;}
float cos01(float t) {return (cos(t)+1)*.5;}
float atan2_01(float2 t) {return (atan2(t.x, t.y) + PI) / (PI * 2);}

#endif