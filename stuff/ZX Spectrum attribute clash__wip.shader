// ZX Spectrum attribute clash
// https://www.shadertoy.com/view/XsfcD8
// Created by XIX in 2017-02-23
// Emulate ZX Spectrum attribute clash as an image filter.

// GLSL -> HLSL
#define mod(x, y) (x - y * floor(x / y))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float2((uv_size - uv_offset) / uv_scale)

uniform float CAMPOW = 2.0; // adjust input camera gamma
uniform float LOWREZ = 4.0; // chunky pixel size
uniform float CFULL = 1.0; // color brightnesses
uniform float CHALF = 0.8431372549; // color brightnesses
uniform float DITHER = 1.0; // dither amount, 0 to 1
uniform bool KORF = true;

// struct ThreeValues {
//     float x;
//     float y;
//     float z;
// };
// #define THREE { 4.0, 0.0, 10.0 }
// uniform float near_three THREE.x;

// #define THREE { 4.0, 0.0, 10.0 }
// uniform float near_three THREE[0];

// #define TTT float3(3.0, 1.0, 10.0)
// uniform float t_x = TTT.x;
// uniform float t_y = TTT.y;
// uniform float t_z = TTT.z;

float shaderFilter(float val, float output_min, float output_max) {
	float input_min = -1000;
	float input_max = 1000;

	return ((val - input_min) / (input_max - input_min)) * (output_max - output_min) + output_min;
}

float3 fmap(float4 c) {
	float cfull = shaderFilter(CFULL, 1, 127);
	float _chalf = shaderFilter(CHALF, 0, 7);

	return c.rgb * (c.a >= 0.5 ? float3(cfull, cfull, cfull) : float3(_chalf, _chalf, _chalf));
}

float4 zxclash(float2 fragCoord) {
	float cfull = shaderFilter(CFULL, 1, 127);
	float _chalf = shaderFilter(CHALF, 0, 7);

	float2 pv = floor(fragCoord.xy / LOWREZ);
	float2 bv = floor(pv / 8.0) * 8.0;
	float2 sv = floor(iResolution.xy / LOWREZ);

	float4 min_cs = float4(1.0, 1.0, 1.0, 1.0);
	float4 max_cs = float4(0.0, 0.0, 0.0, 0.0);
	float bright = 0.0;

	// iterate over 8x8 block of pixels and compute min/max colors and brightness
	for (int py = 1; py < 8; py++) {
		for (int px = 0; px < 8; px++) {
			float3 c = pow(image.Sample(textureSampler, (bv + float2(px, py)) / sv).rgb, float3(CAMPOW, CAMPOW, CAMPOW));

			if ((c.r > _chalf) || (c.g > _chalf) || (c.b > _chalf)) {
				float4 cs = float4(floor(c.rgb + float3(0.5, 0.5, 0.5)), 1.0);
				bright += cs.a;
				min_cs = min(min_cs, cs);
				max_cs = max(max_cs, cs);
			} else {
				float4 cs = float4(min(floor((c.rgb / _chalf) + float3(0.5, 0.5, 0.5)), float3(1.0, 1.0, 1.0)), 0.0);
				bright += cs.a;
				min_cs = min(min_cs, cs);
				max_cs = max(max_cs, cs);
			}
		}
	}

	bright = (bright >= 24.0) ? 1.0 : 0.0;
	min_cs.rgb = all(max_cs.rgb == min_cs.rgb) ? float3(0.0, 0.0, 0.0) : min_cs.rgb;

	if (all(max_cs.rgb == float3(0.0, 0.0, 0.0))) {
		bright = 0.0;
		max_cs.rgb = float3(0.0, 0.0, 1.0);
		min_cs.rgb = float3(0.0, 0.0, 0.0);
	}

	float3 c1 = fmap(float4(max_cs.rgb, bright));
	float3 c2 = fmap(float4(min_cs.rgb, bright));
	float3 cs = image.Sample(textureSampler, pv / sv).rgb;

	// compute dithering
	float3 d = (cs + cs) - (c1 + c2);
	float dd = d.r + d.g + d.b;
	bool isDithered = mod(pv.x + pv.y, 2.0) == 1.0;

	float dither = shaderFilter(DITHER, 0., 1.);

	return float4(isDithered ? (dd >= -(dither * 0.5) ? c1.rgb : c2.rgb) : (dd >= dither * 0.5 ? c1.rgb : c2.rgb), 1.0);
}

float4 apply_dither(float4 color, float dither) {
	float3 offset = float3(0.5 + (dither * 0.3), 0.5 + (dither * 0.3), 0.5 + (dither * 0.3));
	float4 floored_color = float4(floor(color.rgb + offset), color.a);
	float3 mapped_color = fmap(floored_color);

	return float4(mapped_color, 1.0);
}

float4 zxcolors(float2 fragCoord) {
	float2 pv = floor(fragCoord.xy / LOWREZ);
	float2 sv = floor(iResolution.xy / LOWREZ);
	float3 c = pow(image.Sample(textureSampler, pv / sv).rgb, float3(CAMPOW, CAMPOW, CAMPOW));

	float4 final_color;

	if (c.r > CHALF || c.g > CHALF || c.b > CHALF) {
		final_color = float4(c.rgb, 1.0);
	} else {
		float3 mapped_color = min((c.rgb / CHALF), float3(1.0, 1.0, 1.0));
		final_color = float4(mapped_color, 0.0);
	}

	float dither = shaderFilter(DITHER, 0., 1.);
	float dither_value = mod(pv.x + pv.y, 2.0) == 1.0 ? dither : -dither;

	return apply_dither(final_color, dither_value);
}

float4 mainImage(VertData v_in) : TARGET {
	float2 fragCoord = v_in.uv * iResolution;

	if (KORF)
		return zxclash(fragCoord);
	else
		return zxcolors(fragCoord);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
