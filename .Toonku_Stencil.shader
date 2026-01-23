		[Header(Stencil)]
		[Space]
        [IntRange] _StencilRef("    Reference Value", Range(0,255)) = 0
        [IntRange] _StencilReadMask("    Read Mask", Range(0,255)) = 255
        [IntRange] _StencilWriteMask("    Write Mask", Range(0,255)) = 255
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("    Comparison Operation", Float) = 8
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilPass("    Pass Operation", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFail("    Fail Operation", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail("    ZFail Operation", Float) = 0