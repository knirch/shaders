// Fake Pixel Sorting for Video
// https://www.shadertoy.com/view/wljyRz
// Created by curiouspers in 2020-07-01
//
// inspired by cyberpunk game trailer: https://youtu.be/FknHjl7eQ6o?t=52
// and pixel sorting found here: https://www.shadertoy.com/view/XlGXzw
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/
//
// Porting notes: Changed the suggestion to modify the code into booleans.

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

// The textureSampler defined in OBS-Shaderfilter uses 'Border' which produces
// undesirable black boxes, clamping to edge looks much nicer.
sampler_state clampSampler {
	AddressU = D3DTADDRESS_CLAMP;
	AddressV = D3DTADDRESS_CLAMP;
};

uniform bool modulate_offset = true;
uniform bool shake_offset_and_modulate = true;
uniform bool more_noisy_spikes = true;
uniform float max_offset = 80.;

float rand(float co) {
	return frac(sin(co * (91.3458)) * 47453.5453);
}

float4 mainImage(VertData v_in) : TARGET {
	float2 uv = v_in.uv;
	float2 texel = 1. / iResolution.xy;
	float4 img = image.Sample(clampSampler, uv);
	float step_y;

	if (modulate_offset)
		step_y = texel.y * (rand(uv.x) * max_offset) * (sin(sin(iTime * 0.5)) * 2.0 + 1.3);
	else
		step_y = texel.y * (rand(uv.x) * 100.);

	if (shake_offset_and_modulate)
		step_y += rand(uv.x * uv.y * iTime) * 0.025 * sin(iTime);

	if (more_noisy_spikes)
		step_y = lerp(step_y, step_y * rand(uv.x * iTime) * 0.5, sin(iTime));

	if (dot(img, float4(0.299, 0.587, 0.114, 0.)) > 1.2 * (sin(iTime) * 0.325 + 0.50))
		uv.y += step_y;
	else
		uv.y -= step_y;

	return image.Sample(clampSampler, uv);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
