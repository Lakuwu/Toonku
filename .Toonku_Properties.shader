        [Header(Textures)]
		[Space]
		_Color("Color", Color) = (1, 1, 1, 1)
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		[NoScaleOffset] _EmissionTex("Emission", 2D) = "black" {}
		_EmissionMul("Emission Multiplier", Float) = 1
		[ToggleUI] _EmissionMainTexMul("Multiply emission by main texture", Float) = 0
		[Normal][NoScaleOffset] _NormalTex("Normal Map Texture", 2D) = "bump" {}
		_Metalness("Metalness", range(0,1)) = 0
		[NoScaleOffset] _MetalnessTex("Metalness Texture", 2D) = "white" {}
		[ToggleUI] _MetalnessDiffuseMask ("Metalness as Diffuse Mask", Float) = 0
		_Roughness("Roughness", range(0,1)) = 0.5
		_RoughnessMin("RoughnessMin", range(0,1)) = 0
		[NoScaleOffset] _RoughnessTex("Roughness Texture", 2D) = "white" {}
		_EnvMapMask("Environment Mapping", range(0,1)) = 0
		[NoScaleOffset] _EnvMapMaskTex("Environment Mapping Mask", 2D) = "white" {}
		_AlphaClip("Alpha clip", range(0,1)) = 1
		_TexInfluence("Texture influence", range(0,1)) = 1
		
		[Header(Toon shading values)]
		[Space]
		_DiffShadeColor("Diffuse shade color", Color) = (1,1,1,1)
		_DiffShadeColTint("Diffuse shade color tint", range(0,1)) = 0.0
		_DiffShadeStart("Diffuse shade start", range(-1,1)) = 0.0
		_DiffShadeEnd("Diffuse shade end", range(-1,1)) = 0.5
		
		[Space]
		[Toggle] _FRESNEL_REFLECT("Fresnel -> Reflect mode", Float) = 0
		_FresnelShadeColor("Fresnel shade color", Color) = (1,1,1,1)
		_FresnelShadeStart("Fresnel shade start", range(-1,1)) = 0.3
		_FresnelShadeEnd("Fresnel shade end", range(-1,1)) = 0.5
		
		[Space]
		_FresnelLightAmount("Fresnel light amount", range(0,3)) = 0.1
        [NoScaleOffset] _FresnelLightMaskTex("Fresnel light Mask", 2D) = "white" {}
		_FresnelLightColor("Fresnel light color", Color) = (1,1,1,1)
		_FresnelLightStart("Fresnel light start", range(-1,1)) = 0.3
		_FresnelLightEnd("Fresnel light end", range(-1,1)) = 0.5
		_FresnelLightTint("Fresnel light tint", range(0,1)) = 0
		
		[Space]
		_FresnelLightRingStart("Fresnel light ring start", range(0,1)) = 1
		_FresnelLightRingEnd("Fresnel light ring end", range(0,1)) = 1
		_FresnelLightRingMul("Fresnel light ring mul", range(-2,2)) = 1
		[ToggleUI] _FresnelLightRingMode ("Fresnel light ring mode", Float) = 0
		
		[Space]
		_FresnelAlphaValue("Fresnel alpha value", range(0,1)) = 1
		_FresnelAlphaStart("Fresnel alpha start", range(0,1)) = 1
		_FresnelAlphaEnd("Fresnel alpha end", range(0,1)) = 1
		
		[Header(Color Adjustment)]
		[Space]
		_LightnessMul("Lightness/Value Multiplier", Range(-3, 3)) = 1
		_ChromaMul("Chroma/Saturation Multiplier", Range(-3, 3)) = 1
		_HueShift("Hue Shift", Range(-1,1)) = 0
		[ToggleUI] _HueShiftAnim ("Animate Hue Shift", Float) = 0
		[ToggleUI] _HueShiftFresnel ("Fresnel Hue Shift", Float) = 0
		[ToggleUI] _UseHSV("Use HSV instead of OKLAB", Float) = 0
		[NoScaleOffset] _HSVMaskTex("HSV Mask", 2D) = "white" {}
		
		[Header(Specular Iridescent)]
		[Space]
		[Toggle] _IRIDESCENT("Enable", Float) = 0
		_IridescentFresnelMul("FresnelMul", Float) = 1
		_IridescentMul("Mul", Float) = 1
		[NoScaleOffset] _IridescentTex("Texture", 2D) = "white" {}
		
		[Header(Misc)]
		[Space]
		[IntRange] _AnimIdx("Anim Idx", range(0, 7)) = 0
		[ToggleUI] _Debug("Debug Toggle", Float) = 0
		_GeomAngle("Geometry shader angle", range(-1,1)) = 0.0
		[ToggleUI] _MultiplySpecularByVertexCol("Multiply specular by vertex color", Float) = 0
		[ToggleUI] _MultiplyMainByVertexCol("Multiply main color by vertex color", Float) = 0
		[ToggleUI] _FlipBacksideNormals("Flip backside normals", Float) = 1
		
		[Header(Lighting)]
		[Space]
		_MinLight("Minimum Light Value", Range(0,2)) = 0.05
        _FinalBrightness("Final Brightness", Range(0,1)) = 1
		[ToggleUI] _UseSH("Use Spherical Harmonics", Float) = 1
		[ToggleUI] _UseRealtimeLights("Use Realtime Lights", Float) = 1
		[ToggleUI] _SHDirectionalColor("Spherical Harmonics directional color", Float) = 0
		[ToggleUI] _LegacyShading("Legacy shading", Float) = 0
		[ToggleUI] _UseLightVolumes("Use Light Volumes", Float) = 1
		
		[HideInInspector] _HueShift1("",Float) = 0
		[HideInInspector] _HueShift2("",Float) = 0
		[HideInInspector] _HueShift3("",Float) = 0
		[HideInInspector] _HueShift4("",Float) = 0
		[HideInInspector] _HueShift5("",Float) = 0
		[HideInInspector] _HueShift6("",Float) = 0
		[HideInInspector] _HueShift7("",Float) = 0
		[HideInInspector] _HueShiftAnim1 ("", Float) = 0
		[HideInInspector] _HueShiftAnim2 ("", Float) = 0
		[HideInInspector] _HueShiftAnim3 ("", Float) = 0
		[HideInInspector] _HueShiftAnim4 ("", Float) = 0
		[HideInInspector] _HueShiftAnim5 ("", Float) = 0
		[HideInInspector] _HueShiftAnim6 ("", Float) = 0
		[HideInInspector] _HueShiftAnim7 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel1 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel2 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel3 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel4 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel5 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel6 ("", Float) = 0
		[HideInInspector] _HueShiftFresnel7 ("", Float) = 0
		
		[Header(Toggles)]
		[Space]
        [ToggleUI] _Toggle1 ("Hide UV X 1-2", Float) = 0
        [ToggleUI] _Toggle2 ("Hide UV X 2-3", Float) = 0