// <name>
// <url>
// <credits>
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/
//
// Porting notes: Anything of actual interest

// GLSL -> HLSL
#define atan(y, x) atan2(x, y)
#define mod(x, y) (x - y * floor(x / y))
#define length(v) sqrt(dot(v, v))
#define fract frac
#define mix lerp
#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mat2 float2x2
#define mat3 float3x3
#define mat4 float4x4
#define ivec2 int2

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

// Silly - This shouldn't be here.
#define texture image.Sample
#define iChannel0 textureSampler

// For reference, the default textureSampler inserted by OBS-ShaderFilter.
sampler_state textureSampler {
	Filter = Linear;
	AddressU = Border;
	AddressV = Border;
	BorderColor = 00000000;
};

// Any use of texture(iChannel0, ...) should be converted to image.Sample(textureSampler, ...)
// Any calculations for uv can be replaced with v_in.uv. (( ie vec2 UV = fragCoord.xy/iResolution.xy; ))
// WARNING: Any consts used in calculations might get optimized away, always try
// to change to uniform if shader behaves erratic

float4 mainImage(VertData v_in) : TARGET {
	vec4 fragColor;
	vec2 fragCoord = v_in.uv * iResolution;


	fragColor = image.Sample(textureSampler, v_in.uv);

	return fragColor;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
