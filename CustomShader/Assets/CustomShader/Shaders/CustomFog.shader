Shader "Artfx/Custom/Unlit/CustomFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        // see :  https://docs.unity3d.com/ScriptReference/MaterialProperty.PropFlags.html
        [NoScaleOffset] _Mask("Mask", 2D) = "white" {}
        
        _Color("Color", Color) = (1,1,1,1)
        
        _Speed("Speed", float) = 1
        _OffCenter("OffCenter)", Range(0,1)) =0.2
        
    }
    SubShader
    {
        Tags 
        { 
            "Queue"="Transparent" 
            "RenderType"="Transparent"  
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull back
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
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertCol : COLOR0;
            };


            // f/p
            sampler2D _MainTex, _Mask;
            float4 _MainTex_ST;
            float _Speed, _OffCenter;
            fixed4 _Color;
            
            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.vertCol = v.color;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // rotation off-center, to make more realistic effect
                float2 uv = i.uv + float2(sin(_Time.y*_Speed+_OffCenter), cos(_Time.y*_Speed)) * _Speed * _Time.x;
                fixed4 col = tex2D(_MainTex, uv) * _Color * i.vertCol;

                // mix mask alpha 
                col.a *= tex2D(_Mask, uv ).r * i.vertCol;

                // disappear effect 
                col.a *= lerp(0.2, 1, saturate(sin(_Time.y* _Speed)));

                // blend on mask start to break square effect
                col.a *= smoothstep(1, 0.95, uv.x);
                col.a *= smoothstep(0, 0.05, uv.x);
                
                col.a *= smoothstep(1, 0.95, uv.y);
                col.a *= smoothstep(0, 0.05, uv.y);
                
                return col;
            }
            ENDCG
        }
    }
}