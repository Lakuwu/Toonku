#include "UnityCG.cginc"

// sampler2D _RandomDirTex;

float time() {
    return _Time.y * 1;
}
float time2() {
    return _Time.y * 0.71;
}
float time3() {
    return _Time.y * 0.79;
}
float3 noise3(float2 a) {
    float f = sin(dot(a, float2(36.12345, 15.40956)));
    return float3(
        frac(f * 3216.15683),
        frac(f * 1637.97514),
        frac(f * 2754.32947)
    );
}

float3 hsv2rgb_fireworks(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float sphIntersect1(float3 ro, float3 rd, float3 ce, float ra) {
    float3 oc = ro - ce;
    float b = dot(oc, rd);
    float3 qc = oc - b * rd;
    float h = ra * ra - dot(qc, qc);
    [branch]if(h < 0.0) return -1;
    h = sqrt(h);
    return -b - h;
}

float unpack(float f) {
    return (f * 255 - 127) / 255;
}

float3 unpack3(float3 f) {
    return float3(unpack(f.x), unpack(f.y), unpack(f.z));
} 

float do_firework(float3 camera_pos, float3 dir, float u, float r, float3 s_origin) {
    float b = 0;
    float d = 1000000;
    float l0 = 1 - (u % 4) * 0.2;
    // float3 l1 = .5;
    float3 l1 = .5 + (u % 4) * 0.1;
    // float3 l2 = float3(1, 0.01, 1);
    float3 l2 = float3(1 - (u % 5) * 0.15, 1 - (u % 6) * 0.14, 1 - (u % 7) * 0.13);
    [branch]if(sphIntersect1(camera_pos, dir, s_origin, r) < 0.0) return 0;
    float3 res = float3(0,0,0);
    // n < 13 was the old number, thats what i deemed ok on my old 1070 ti but my new 4070 super can handle way larger amounts so i guess its fine to crank it up :)
    uint count = 15 + (u % 3) * 25;
    for(uint n = 0; n < count; ++n) {
        float3 rand = noise3(float2(n, u));
        // idk sampling a texture too many times makes the compiler hang so i guess im not doing that
        // float3 dir1 = unpack3(tex2D(_RandomDirTex, float2((u + n) / 4096, 0.5))) * r;
        float3 dir1 = normalize(rand*2-1) * r;
        float3 s_pos = s_origin + dir1 * l1;
        float s0 = sphIntersect1(camera_pos, dir, s_pos, .002);
        [branch]
        if(s0 >= 0 && s0 < d) {
            d = s0;
            float3 si_pos = camera_pos + dir * s0;
            b = dot(normalize(si_pos - s_pos), -dir);
        }
        s_pos = s_origin - dir1 * l1;
        s0 = sphIntersect1(camera_pos, dir, s_pos, .002);
        [branch]
        if(s0 >= 0 && s0 < d) {
            d = s0;
            float3 si_pos = camera_pos + dir * s0;
            b = dot(normalize(si_pos - s_pos), -dir);
        }   
             
        s_pos = s_origin + dir1.zyx * l1;
        s0 = sphIntersect1(camera_pos, dir, s_pos, .002);
        [branch]
        if(s0 >= 0 && s0 < d) {
            d = s0;
            float3 si_pos = camera_pos + dir * s0;
            b = dot(normalize(si_pos - s_pos), -dir);
        } 
        s_pos = s_origin - dir1.zyx * l1;
        s0 = sphIntersect1(camera_pos, dir, s_pos, .002);
        [branch]
        if(s0 >= 0 && s0 < d) {
            d = s0;
            float3 si_pos = camera_pos + dir * s0;
            b = dot(normalize(si_pos - s_pos), -dir);
        }   
             
        s_pos = s_origin + dir1.yzx * l2;
        s0 = sphIntersect1(camera_pos, dir, s_pos, .002);
        [branch]
        if(s0 >= 0 && s0 < d) {
            d = s0;
            float3 si_pos = camera_pos + dir * s0;
            b = dot(normalize(si_pos - s_pos), -dir);
        }
        s_pos = s_origin - dir1.yzx * l2;
        s0 = sphIntersect1(camera_pos, dir, s_pos, .002);
        [branch]
        if(s0 >= 0 && s0 < d) {
            d = s0;
            float3 si_pos = camera_pos + dir * s0;
            b = dot(normalize(si_pos - s_pos), -dir);
        }
        
        s_pos = s_origin + dir1.zxy * l2;
        s0 = sphIntersect1(camera_pos, dir, s_pos, .002);
        [branch]
        if(s0 >= 0 && s0 < d) {
            d = s0;
            float3 si_pos = camera_pos + dir * s0;
            b = dot(normalize(si_pos - s_pos), -dir);
        }
        s_pos = s_origin - dir1.zxy * l2;
        s0 = sphIntersect1(camera_pos, dir, s_pos, .002);
        [branch]
        if(s0 >= 0 && s0 < d) {
            d = s0;
            float3 si_pos = camera_pos + dir * s0;
            b = dot(normalize(si_pos - s_pos), -dir);
        }
    }
    return b;
    // [branch]if(d == 1000000) return 0;
    // return dot(normalize(camera_pos + dir * d - s_pos_res), -dir) * (d != 1000000);
}

float3 do_fireworks(v2fa i) {
    float3 dir = normalize(i.opos - i.camera_pos);
    
    float t0 = time();
    float t = frac(t0);
    float tt = 1 - t;
    float u = floor(t0);
    
    float hue0 = i.random.x * 3;
    float3 s_origin = (i.random*2-1) * .3;
    // float3 s_origin = float3(0,0,0);
    float s_radius = lerp(0.1,0.2, i.random.z);
    // float s_radius = .1;
    float r = (1-tt*tt) * s_radius;
    // float r = s_radius;
    float b = do_firework(i.camera_pos, dir, u, r, s_origin);
    float3 col0 = hsv2rgb_fireworks(float3(hue0, (1-b*b*b)*2, b*b*3)) * pow(tt,.4);
    
    float t1 = time2();
    t = frac(t1);
    tt = 1 - t;
    u = floor(t1);
    float hue1 = i.random1.x * 3;
    s_origin = (i.random1*2-1) * .3;
    s_radius = lerp(0.1,0.2, i.random1.z);
    r = (1-tt*tt) * s_radius;
    b = do_firework(i.camera_pos, dir, u, r, s_origin);
    float3 col1 = hsv2rgb_fireworks(float3(hue1, (1-b*b*b)*2, b*b*3)) * pow(tt,.4);
    
    float t2 = time3();
    t = frac(t2);
    tt = 1 - t;
    u = floor(t2);
    float hue2 = i.random2.x * 3;
    s_origin = (i.random2*2-1) * .3;
    s_radius = lerp(0.1,0.2, i.random2.z);
    r = (1-tt*tt) * s_radius;
    b = do_firework(i.camera_pos, dir, u, r, s_origin);
    float3 col2 = hsv2rgb_fireworks(float3(hue2, (1-b*b*b)*2, b*b*3)) * pow(tt,.4);
    return max(col0, max(col1, col2));
}
