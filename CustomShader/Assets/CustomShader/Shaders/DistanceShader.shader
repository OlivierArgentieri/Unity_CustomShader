Shader "Artfx/Custom/Unlit/DistanceShader"
{
    Properties
    {
        _MainTex ( "Main Texture", 2D ) = "white" {}
        _Range ( "Radius", Range(0.001, 50) ) = 10
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            ZWrite off
            ZTest Less
            
            CGPROGRAM
            #include "UnityCG.cginc"
            // buffer
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 position : POSITION;   
                float2 uv : TEXCOORD0;
            };

            float _MinDistance;
            float _MaxDistance;

            // vertex to fragment
            struct v2f
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float _Range;
            // vertex shader
            v2f vert (appdata v)
            {
                v2f o; // out attr
                o.position = UnityObjectToClipPos(v.position);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.position); // to world pos
                return o;
            }

            // fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv); // Texture Lookup
                float newAlpha = distance(i.worldPos, _WorldSpaceCameraPos) / _Range;

                col.a  = saturate(newAlpha);
                return col;
                
            }
            ENDCG
        }
    }
}
