// Pixel Sorting for Video
// https://www.shadertoy.com/view/XlGXzw
// Created by robgonsalves in 2017-01-03
//
// This is a variation of the Pixel Sorting shader by @cornusammonis here
// https://www.shadertoy.com/view/XdcGWf
//
// It works on video by blending the sorted image to the incoming video by  a
// factor of 100 to 1.
//
// Also uses real luminance equation.
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

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

	// fragColor = image.Sample(textureSampler, v_in.uv);

	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 texel = 1. / iResolution.xy;

	float step_y = texel.y;
	vec2 s = vec2(0.0, -step_y);
	vec2 n = vec2(0.0, step_y);

	vec4 im_n = texture(iChannel0, v_in.uv + n);
	vec4 im = texture(iChannel0, v_in.uv);
	vec4 im_s = texture(iChannel0, v_in.uv + s);

	// use luminance for sorting
	float len_n = dot(im_n, vec4(0.299, 0.587, 0.114, 0.));
	float len = dot(im, vec4(0.299, 0.587, 0.114, 0.));
	float len_s = dot(im_s, vec4(0.299, 0.587, 0.114, 0.));

	if (int(mod(float(iFrame) + fragCoord.y, 2.0)) == 0) {
		if ((len_s > len))
			im = im_s;
	} else {
		if ((len_n < len))
			im = im_n;
	}

	// blend with image
	if (iFrame < 1)
		fragColor = image.Sample(textureSampler, v_in.uv);
	else
		fragColor = (image.Sample(textureSampler, v_in.uv) + im * 99.) / 100.;

	return fragColor;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
