// cheap outline and cartoon effect
// https://www.shadertoy.com/view/MljfWw
// Created by public_int_i in 2018-01-17
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define atan(y, x) atan2(x, y)
#define fract frac
#define mix lerp
#define mod(x, y) (x - y * floor(x / y))
#define vec2 float2
#define vec3 float3
#define vec4 float4
#define length(v) sqrt(dot(v, v))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)

// The textureSampler defined in OBS-Shaderfilter uses 'Border' which produces
// undesirable black boxes, clamping to edge looks much nicer.
sampler_state clampSampler {
	AddressU = D3DTADDRESS_CLAMP;
	AddressV = D3DTADDRESS_CLAMP;
};

#define SL_MIN -1000.
#define SL_MAX 1000.
#define sfClamp(v, lower, upper) (((v - SL_MIN) / (SL_MAX - SL_MIN)) * (upper - lower) + lower)
#define deClamp(v, lower, upper) (((v - lower) / (upper - lower)) * (SL_MAX - SL_MIN) + SL_MIN)

#pragma message "Debugging flag set."

#define OUTLINE_COLOR vec4(.2, .2, .2, .2)
uniform float OUTLINE_STRENGTH = 20.;
OUTLINE_STRENGTH = sfClamp(20., 0., 2.);
uniform float OUTLINE_BIAS = deClamp(.5, 0., 2.);
uniform float OUTLINE_POWER = deClamp(0.7, 0., 2.);

uniform float PRECISION = deClamp(6., 0., 10.);

// #define OUTLINE_STRENGTH 20.
// #define OUTLINE_BIAS -.5
// #define OUTLINE_POWER 1.
// #define PRECISION 6.

float4 mainImage(VertData v_in) : TARGET {
	vec4 o;
	vec2 u = v_in.uv * iResolution;
	vec2 r = iResolution.xy;
	vec4 p = pow(image.Sample(textureSampler, u / r), vec4(2.2, 2.2, 2.2, 2.2));
	vec4 s = pow(image.Sample(textureSampler, (u + .5) / r), vec4(2.2, 2.2, 2.2, 2.2));

	float _OUTLINE_STRENGTH = sfClamp(OUTLINE_STRENGTH, 0., 2.);
	float _OUTLINE_BIAS = sfClamp(OUTLINE_BIAS, 0., 2.);
	float _OUTLINE_POWER = sfClamp(OUTLINE_POWER, 0., 2.);
	float _PRECISION = sfClamp(PRECISION, 0., 10.);

	float l = clamp(pow(length(p - s), _OUTLINE_POWER) * _OUTLINE_STRENGTH + _OUTLINE_BIAS, 0., 1.);
	p = floor(pow(p, (1. / 2.2)) * (_PRECISION + .999)) / _PRECISION;
	o = mix(p, OUTLINE_COLOR, l);

	return o;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
