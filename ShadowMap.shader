Shader "USB/ShadowMapping/ShadowMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        //shadow caster pass
        Pass
        {
            Name "Shadow Caster"
            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ShadowCaster"
            }
            ZWrite On

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCg.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            /*struct appdata
            {
                // we need only the position of vertices as input
                float4 vertex : POSITION;
            };*/

            /*struct v2f
            {
                // we need only the position of vertices as output
                float4 vertex : SV_POSITION;
            };*/

            v2f vert (appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET (o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT (i)
            }

            ENDCG
        }
        //default color pass
        Pass
        {
            Name "Shadow Map Texture"
            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                // declare the UV coordinates for the shadow map
                float4 shadowCoord : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // declare a sampler for the shadow map
            sampler2D _ShadowMapTexture;

            // declare NDCToUV above the vertex shader stage
            float4 NDCToUV(float4 clipPos)
            {
                float4 uv = clipPos;
                #if defined(UNITY_HALF_TEXEL_OFFSET)
                uv.xy = float2(uv.x,uv.y * _ProjectionParams.x) + uv.w *
                _ScreenParams.zw;
                #else
                uv.xy = float2(uv.x,uv.y * _ProjectionParams.x) + uv.w;
                #endif
                uv.xy = float2(uv.x / uv.w, uv.y / uv.w) * 0.5;
                return uv;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.shadowCoord = NDCToUV(o.vertex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // save the shadow texture in the shadow variable
                fixed shadow = tex2D(_ShadowMapTexture, i.shadowCoord).a;
                col.rgb *= shadow;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
