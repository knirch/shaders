// cheap outline and cartoon effect
// https://www.shadertoy.com/view/MljfWw
// Created by public_int_i in 2018-01-17
//
// Ethan Alexander Shulman 2018
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define length(v) sqrt(dot(v, v))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)

// The textureSampler defined in OBS-Shaderfilter uses 'Border' which produces
// undesirable black boxes, clamping to edge looks much nicer.
sampler_state clampSampler {
	AddressU = D3DTADDRESS_CLAMP;
	AddressV = D3DTADDRESS_CLAMP;
};

uniform float4 OUTLINE_COLOR = {.2, .2, .2, 1};
uniform float OUTLINE_STRENGTH = 20.;
uniform float OUTLINE_BIAS = -.5;
uniform float OUTLINE_POWER = 1.;

uniform float PRECISION = 6.;

float4 mainImage(VertData v_in) : TARGET {
	float2 u = v_in.uv * iResolution;
	float2 r = iResolution.xy;
	float4 p = pow(image.Sample(textureSampler, u / r), float4(2.2, 2.2, 2.2, 2.2));
	float4 s = pow(image.Sample(textureSampler, (u + .5) / r), float4(2.2, 2.2, 2.2, 2.2));

	float l = clamp(pow(length(p - s), OUTLINE_POWER) * OUTLINE_STRENGTH + OUTLINE_BIAS, 0., 1.);
	p = floor(pow(p, (1. / 2.2)) * (PRECISION + .999)) / PRECISION;

	return lerp(p, OUTLINE_COLOR, l);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
