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
// Any calculations for uv can be replaced with v_in.uv.

// Potential dumb idea about setting clamped values for the uniform floats;
// default value, min value, max value
#define parameter_xyz float3(1.0, 0., 10.)
#define HEJname foo
#define HEJmax parameter_xyz.z
#define HEJmin parameter_xyz.y
#define HEJdef parameter_xyz.x
uniform float foo = 1.0;

#define SL_MIN -1000.0
#define SL_MAX 1000.0
#define SLIDER_TO_VALUE(v, lower, upper) (((v - SL_MIN) / (SL_MAX - SL_MIN)) * (upper - lower) + lower)
#define VALUE_TO_SLIDER(v, lower, upper) (((v - lower) / (upper - lower)) * (SL_MAX - SL_MIN) + SL_MIN)

#define foo_limits float3(6.0, -2., 10.)
uniform float foo = 1.0; // -1000 -> 1000 range converted, actual value above
#define foo_slider foo
#define foo_max foo_limits.z

// this is what the slider should default to. NO idea how to pull that out :)
// Maybe via an init function?
#define foo__korv VALUE_TO_SLIDER(foo_limits.x, foo_limits.y, foo_limits.z)

// nope, nothing can change those values, only the plugin is allowed to do that.
// globals regardless of uniform or not, are considered constant and will result
// in errors from the compiler

float3 encode_value(float value) {
	// Limit the value within the range -1000 to 1000
	value = saturate(value / 1000.0);
	// Scale the value by 255 and convert to byte
	float3 encoded_float3 = float3(value, value * 0.00392156863, value * 0.00001562102);

	return encoded_float3;
}

// WARNING: Any consts used in calculations might get optimized away, always try
// to change to uniform if shader behaves erratic

float4 mainImage(VertData v_in) : TARGET {
	vec4 fragColor;
	vec2 fragCoord = v_in.uv * iResolution;

	return float4(encode_value(foo__korv), 1.);

	if (foo__korv > 0.)
		return float4(1.0, 0.0, 0., 0.5);

	// if(foo_slider > foo_max)
	// return float4(1.0, 0.0, 0., 1.);
	// if(foo > 2.0)
	// return float4(1.0, 1.0, 0., 1.);

	fragColor = image.Sample(textureSampler, v_in.uv);

	return fragColor;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
