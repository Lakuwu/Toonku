		[Header(Stencil)]
		[Space]
        _StencilRef("Reference Value", Integer) = 0
        _StencilReadMask("Read Mask", Integer) = 255
        _StencilWriteMask("Write Mask", Integer) = 255
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Comparison Operation", Float) = 8
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilPass("Pass Operation", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFail("Fail Operation", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail("ZFail Operation", Float) = 0