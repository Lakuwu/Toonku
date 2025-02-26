		[Header(Rendering)]
        [Space]
        [ToggleUI] _ZWrite ("ZWrite", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcBase("Base Blend Src", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstBase("Base Blend Dst", Float) = 10
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpBase("Base Blend Op", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcAlphaBase("Base Blend Alpha Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstAlphaBase("Base Blend Alpha Dst", Float) = 10
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpAlphaBase("Base Blend Alpha Op", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcAdd("Add Blend Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstAdd("Add Blend Dst", Float) = 1
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpAdd("Add Blend Op", Float) = 4
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcAlphaAdd("Add Blend Alpha Src", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstAlphaAdd("Add Blend Alpha Dst", Float) = 1
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpAlphaAdd("Add Blend Alpha Op", Float) = 4