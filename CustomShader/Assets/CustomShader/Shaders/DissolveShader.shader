Shader "Artfx/Custom/Unlit/DissolveShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _Mask("Mask", 2D) = "white" {}
        
        _EmissiveColor("Emissive Color", Color) = (1,1,1,1)
        _EmissiveWeight("Emissive Weight", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags 
        { 
            "Queue"="Transparent" 
            "RenderType"="Transparent"
             "IgnoreProjector"="True"  
        }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull off

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 emission : COLOR0;
                
            };

            sampler2D _MainTex, _Mask;
            float4 _MainTex_ST;
            float4 _EmissiveColor;
            float _EmissiveWeight;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv, _MainTex;
                o.emission.rgb = _EmissiveColor.rgb;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture and mask
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_Mask, i.uv);

                
                // shift time and add emissive
                if (saturate(_SinTime.x+_EmissiveWeight) > mask.r )
                {
                    col.rgb += i.emission.rgb * 2;
                }

                // on realtime -> dissolve effect
                if (saturate(_SinTime.x) > mask.r )
                {
                    col.a = 0;
                }
               
                return col;
            }
            ENDCG
        }
    }
}
