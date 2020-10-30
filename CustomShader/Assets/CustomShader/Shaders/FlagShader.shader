Shader "Artfx/Custom/Unlit/FlagShader"
{
   Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        
        _Frequency("Frequency", float) = 1
        _Amplitude("Amplitude", float) = 1
        _Speed("Speed", float) = 1
    }
    SubShader
    {
        Tags 
        {
             "RenderType" = "Transparent"
             "Queue" = "Transparent"
             "IgnoreProjector" = "True"
        }
        cull off
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha 
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

            uniform float _Frequency;
            uniform float _Amplitude;
            uniform float _Speed;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float4 texcoord: TEXCOORD0; 
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 texcoord : TEXCOORD0;
            };

            float4 vertexAnimFlag(float4 _vertPos, float2 uv)
            {
                // improve floating effect
                float lag = _vertPos.x+_vertPos.y+_vertPos.z; 
                
                float time= _Time.y;

				// to fix the left part
                float _mult = smoothstep(0.005, 1, uv.x);
            
                _vertPos.y +=  (_mult * sin((uv.x - (time *_Speed) + lag )* _Frequency) * _Amplitude);
                return _vertPos;
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                v.vertex = vertexAnimFlag(v.vertex, v.texcoord);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = float4(0,0,0,0);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw); // tilling xy : scale, zw : offset 
                return o;
            }

            
            fixed4 frag (v2f i) : COLOR
            {
                float4 color = tex2D(_MainTex, i.texcoord) * _Color;

				// blend last pixel to improve movement effect
                color.a = smoothstep(1, 0.95, i.texcoord.x);
                return color;
            }
            ENDCG
        }
    }
}
