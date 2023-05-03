// MattiasCRT
// https://www.shadertoy.com/view/Ms23DR
// Created by Mattias in 2013-12-08
//
// Loosely based on postprocessing shader by inigo quilez, License Creative
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define mod(x, y) (x - y * floor(x / y))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

float2 curve(float2 uv) {
	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;
	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	uv = (uv / 2.0) + 0.5;
	uv = uv * 0.92 + 0.04;

	return uv;
}

float4 mainImage(VertData v_in) : TARGET {
	float2 fragCoord = v_in.uv * iResolution;
	float2 uv = curve(v_in.uv);
	float3 col;
	float x = sin(0.3 * iTime + uv.y * 21.0) * sin(0.7 * iTime + uv.y * 29.0) * sin(0.3 + 0.33 * iTime + uv.y * 31.0) * 0.0017;

	col.r = image.Sample(textureSampler, float2(x + uv.x + 0.001, uv.y + 0.001)).x + 0.05;
	col.g = image.Sample(textureSampler, float2(x + uv.x + 0.000, uv.y - 0.002)).y + 0.05;
	col.b = image.Sample(textureSampler, float2(x + uv.x - 0.002, uv.y + 0.000)).z + 0.05;
	col.r += 0.08 * image.Sample(textureSampler, 0.75 * float2(x + 0.025, -0.027) + float2(uv.x + 0.001, uv.y + 0.001)).x;
	col.g += 0.05 * image.Sample(textureSampler, 0.75 * float2(x + -0.022, -0.02) + float2(uv.x + 0.000, uv.y - 0.002)).y;
	col.b += 0.08 * image.Sample(textureSampler, 0.75 * float2(x + -0.02, -0.018) + float2(uv.x - 0.002, uv.y + 0.000)).z;

	col = clamp(col * 0.6 + 0.4 * col * col * 1.0, 0.0, 1.0);

	// Vignette
	float vignetteIntensity = (0.0 + 1.0 * 16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
	col *= pow(vignetteIntensity, 0.3);

	// Color shift + brightness
	col *= float3(0.95, 1.05, 0.95);
	col *= 2.8;

	// Vertical scanlines
	float scans = clamp(0.35 + 0.35 * sin(3.5 * iTime + fragCoord.y * 1.5), 0.0, 1.0);
	float s = pow(scans, 1.7);
	col *= 0.4 + 0.7 * s;

	// Pulsing
	col *= 1.0 + 0.01 * sin(110.0 * iTime);

	if (uv.x < 0.0 || uv.x > 1.0)
		col *= 0.0;

	if (uv.y < 0.0 || uv.y > 1.0)
		col *= 0.0;

	// Horizontal scanlines
	col *= 1.0 - 0.65 * clamp((mod(fragCoord.x, 2.0) - 1.0) * 2.0, 0.0, 1.0);

	return float4(col, 1.0);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
