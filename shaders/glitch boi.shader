// glitch boi
// https://www.shadertoy.com/view/MltBzf
// Created by boysx in 2018-10-26
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

float rand(float2 p) {
	float t = floor(iTime * 20.) / 10.;

	return frac(sin(dot(p, float2(t * 12.9898, t * 78.233))) * 43758.5453);
}

float noise(float2 uv, float blockiness) {
	float2 lv = frac(uv);
	float2 id = floor(uv);
	float n1 = rand(id);
	float n2 = rand(id + float2(1, 0));
	float n3 = rand(id + float2(0, 1));
	float n4 = rand(id + float2(1, 1));
	float2 u = smoothstep(0.0, 1.0 + blockiness, lv);

	return lerp(lerp(n1, n2, u.x), lerp(n3, n4, u.x), u.y);
}

float fbm(float2 uv, int count, float blockiness, float complexity) {
	float val = 0.0;
	float amp = 0.5;
	while (count != 0) {
		val += amp * noise(uv, blockiness);
		amp *= 0.5;
		uv *= complexity;
		count--;
	}

	return val;
}

uniform float glitchAmplitude = 0.2; // increase this
uniform float glitchNarrowness = 4.0;
uniform float glitchBlockiness = 2.0;
uniform float glitchMinimizer = 5.0; // decrease this

float4 mainImage(VertData v_in ) : TARGET {
	float2 uv = v_in.uv;
	float2 a = float2(uv.x * (iResolution.x / iResolution.y), uv.y);
	float2 uv2 = float2(a.x / iResolution.x, exp(a.y));
	float2 id = floor(uv * 8.0);

	// Generate shift amplitude
	float shift = glitchAmplitude * pow(fbm(uv2, int(rand(id) * 6.), glitchBlockiness, glitchNarrowness), glitchMinimizer);

	// Create a scanline effect
	float scanline = abs(cos(uv.y * 400.));
	scanline = smoothstep(0.0, 2.0, scanline);
	shift = smoothstep(0.00001, 0.2, shift);

	// Apply glitch and RGB shift
	float colR = image.Sample(textureSampler, float2(uv.x + shift, uv.y)).r * (1. - shift);
	float colG = image.Sample(textureSampler, float2(uv.x - shift, uv.y)).g * (1. - shift) + rand(id) * shift;
	float colB = image.Sample(textureSampler, float2(uv.x - shift, uv.y)).b * (1. - shift);

	// Mix with the scanline effect
	float3 f = float3(colR, colG, colB) - (0.1 * scanline);

	// Output to screen
	return float4(f, 1.0);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
