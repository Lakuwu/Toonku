        [Header(Base Color)]
		[Space]
		_Color("    Color", Color) = (1, 1, 1, 1)
		[NoScaleOffset] _MainTex("    Main Texture", 2D) = "white" {}
		_TexInfluence("    Texture Influence", range(0,1)) = 1
		
		[Header(Alpha Transparency)]
		[Space]
		[NoScaleOffset] _AlphaTex("    Alpha Mask", 2D) = "white" {}
		_AlphaStart("    Alpha Start", range(0,1)) = 0
		_AlphaEnd("    Alpha End", range(0,1)) = 1
		_AlphaClip("    Alpha Clip", range(0,1)) = 1
		
		[Header(Emission)]
		[Space]
		[NoScaleOffset] _EmissionTex("    Emission Texture", 2D) = "black" {}
		_EmissionMul("    Emission Multiplier", Float) = 1
		[ToggleUI] _EmissionMainTexMul("    Multiply Emission by Main Texture", Float) = 0
		
		[Header(Normal Mapping)]
		[Space]
		[Normal] _NormalTex("    Normal Map Texture", 2D) = "bump" {}
		_NormalMapMul("    Normal Map Strength", Float) = 1
		
		[Header(Environment Mapping)]
		[Space]
		_EnvMapMask("    Environment Mapping Strength", range(0,1)) = 0
		[NoScaleOffset] _EnvMapMaskTex("    Environment Mapping Mask", 2D) = "white" {}
		_Metalness("    Metalness", range(0,1)) = 0
		[NoScaleOffset] _MetalnessTex("    Metalness Texture", 2D) = "white" {}
		[ToggleUI] _MetalnessDiffuseMask ("    Metalness as Diffuse Mask", Float) = 0
		[Space]
		_Roughness("    Roughness", range(0,1)) = 0.5
		_RoughnessMin("    RoughnessMin", range(0,1)) = 0
		[NoScaleOffset] _RoughnessTex("    Roughness Map Texture", 2D) = "white" {}
		
		[Header(Shadow)]
		[Space]
		_DiffShadeColor("    Shadow Color", Color) = (0.67,0.67,0.67,1)
		_DiffShadeColTint("    Shadow Color Tint", range(0,1)) = 0.0
		_DiffShadeStart("    Shadow Start", range(-1,1)) = -0.25
		_DiffShadeEnd("    Shadow End", range(-1,1)) = 0.5
		
		[Header(Fresnel Shade)]
		[Space]
		_FresnelShadeColor("    Fresnel Shade Color", Color) = (0.816,0.816,0.816,1)
		_FresnelShadeStart("    Fresnel Shade Start", range(-1,1)) = 0.0
		_FresnelShadeEnd("    Fresnel Shade End", range(-1,1)) = 0.7
		
		[Header(Fresnel Light)]
		[Space]
		_FresnelLightAmount("    Fresnel Light Amount", range(0,3)) = 0.25
        [NoScaleOffset] _FresnelLightMaskTex("    Fresnel Light Mask", 2D) = "white" {}
		_FresnelLightColor("    Fresnel Light Color", Color) = (1,1,1,1)
		_FresnelLightTint("    Fresnel Light Tint", range(0,1)) = 0
		_FresnelLightStart("    Fresnel Light Start", range(-1,1)) = 0.0
		_FresnelLightEnd("    Fresnel Light End", range(-1,1)) = 0.5
		
		[Space]
		_FresnelLightRingStart("    Fresnel Light Ring Start", range(-1,1)) = 1
		_FresnelLightRingEnd("    Fresnel Light Ring End", range(-1,1)) = 1
		_FresnelLightRingMul("    Fresnel Light Ring Mul", range(-2,2)) = 1
		[ToggleUI] _FresnelLightRingMode ("    Fresnel Light Ring Mode", Float) = 0
		
		[Space]
		[Toggle] _FRESNEL_REFLECT("    Fresnel -> Reflect mode", Float) = 0
		
		[Header(Fresnel Alpha)]
		[Space]
		_FresnelAlphaValue("    Fresnel Alpha Value", range(0,1)) = 1
		_FresnelAlphaStart("    Fresnel Alpha Start", range(0,1)) = 1
		_FresnelAlphaEnd("    Fresnel Alpha End", range(0,1)) = 1
		
		[Header(Color Adjustment)]
		[Space]
		_LightnessMul("    Lightness/Value Multiplier", Range(-3, 3)) = 1
		_ChromaMul("    Chroma/Saturation Multiplier", Range(-3, 3)) = 1
		_HueShift("    Hue Shift", Range(-1,1)) = 0
		[ToggleUI] _HueShiftAnim ("    Animate Hue Shift", Float) = 0
		[ToggleUI] _HueShiftFresnel ("    Fresnel Hue Shift", Float) = 0
		[ToggleUI] _UseHSV("    Use HSV instead of OKLAB", Float) = 0
		[NoScaleOffset] _HSVMaskTex("    HSV Mask", 2D) = "white" {}
		
		[Header(Specular Iridescent)]
		[Space]
		[Toggle] _IRIDESCENT("    Enable", Float) = 0
		_IridescentFresnelMul("    FresnelMul", Float) = 1
		_IridescentMul("    Mul", Float) = 1
		[NoScaleOffset] _IridescentTex("    Texture", 2D) = "white" {}
		
		[Header(Misc)]
		[Space]
		[IntRange] _AnimIdx("    Anim Idx", range(0, 7)) = 0
		[ToggleUI] _Debug("    Debug Toggle", Float) = 0
		// _GeomAngle("    Geometry Shader Angle", range(-1,1)) = 0.0
		[ToggleUI] _MultiplySpecularByVertexCol("    Multiply Specular by Vertex Color", Float) = 0
		[ToggleUI] _MultiplyMainByVertexCol("    Multiply Base Color by Vertex Color", Float) = 0
		[ToggleUI] _FlipBacksideNormals("    Flip Backside Normals", Float) = 1
		
		[Header(Lighting)]
		[Space]
		_MinLight("    Minimum Light Value", Range(0,2)) = 0.05
        _FinalBrightness("    Final Brightness", Range(0,1)) = 1
		[ToggleUI] _UseSH("    Use Spherical Harmonics", Float) = 1
		[ToggleUI] _UseRealtimeLights("    Use Realtime Lights", Float) = 1
		[ToggleUI] _SHDirectionalColor("    Spherical Harmonics Directional Color", Float) = 0
		[ToggleUI] _LegacyShading("    Legacy Shading", Float) = 0
		[ToggleUI] _UseLightVolumes("    Use Light Volumes", Float) = 1
		
		[HideInInspector] _HueShift1("",Float) = 0
		[HideInInspector] _HueShift2("",Float) = 0
		[HideInInspector] _HueShift3("",Float) = 0
		[HideInInspector] _HueShift4("",Float) = 0
		// [HideInInspector] _HueShift5("",Float) = 0
		// [HideInInspector] _HueShift6("",Float) = 0
		// [HideInInspector] _HueShift7("",Float) = 0
		[HideInInspector] _HueShiftAnim1 ("", Float) = 0
		[HideInInspector] _HueShiftAnim2 ("", Float) = 0
		[HideInInspector] _HueShiftAnim3 ("", Float) = 0
		[HideInInspector] _HueShiftAnim4 ("", Float) = 0
		// [HideInInspector] _HueShiftAnim5 ("", Float) = 0
		// [HideInInspector] _HueShiftAnim6 ("", Float) = 0
		// [HideInInspector] _HueShiftAnim7 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel1 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel2 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel3 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel4 ("", Float) = 0
		// [HideInInspector] _HueShiftFresnel5 ("", Float) = 0
		// [HideInInspector] _HueShiftFresnel6 ("", Float) = 0
		// [HideInInspector] _HueShiftFresnel7 ("", Float) = 0
		
		[Header(UV Toggles)]
		[Space]
        [ToggleUI] _Toggle1 ("    Hide UV X 1-2", Float) = 0
        [ToggleUI] _Toggle2 ("    Hide UV X 2-3", Float) = 0