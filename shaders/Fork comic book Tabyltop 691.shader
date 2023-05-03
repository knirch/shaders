// Fork comic book Tabyltop 691
// https://www.shadertoy.com/view/mlSXDG
// Created by Tabyltop in 1676499731
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Utility macro as I'm too dumb to figure out how to do it as a #define float3x3...
#define transpose(m) float3x3(m[0][0], m[1][0], m[2][0], \
	                      m[0][1], m[1][1], m[2][1], \
	                      m[0][2], m[1][2], m[2][2])

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)

#define yuv_2_rgb transpose(float3x3(1.0, 1.0, 1.0, \
	                             0.0, -0.39465, 2.03211, \
	                             1.13983, -0.58060, 0.0))
#define rgb_2_yuv transpose(float3x3(0.299, -0.14713, 0.615, \
	                             0.587, -0.28886, -0.51499, \
	                             0.114, 0.436, -0.10001))

float edge(float2 uv, float stepsize) {
	float x = length(image.Sample(textureSampler, uv - float2(stepsize, 0.0)).rgb -
	                 image.Sample(textureSampler, uv + float2(stepsize, 0.0)).rgb);

	float y = length(image.Sample(textureSampler, uv - float2(0.0, stepsize)).rgb -
	                 image.Sample(textureSampler, uv + float2(0.0, stepsize)).rgb);

	return (x + y) / stepsize;
}

float sign1(float x) {
	return (x > 0.0) ? 1.0 : (x < 0.0) ? -1.0 : 0.0;
}

float sign2(float x) {
	return 2.0 * step(0.0, x) - 1.0;
}

float3 color_quantize_yuv(float3 color) {
	const float yuv_step = 0.1;
	float3 yuv = mul(rgb_2_yuv, color);
	yuv.x = 0.2 + 0.8 * yuv.x;
	float3 quantized = float3(0.1 * (0.2 + round(10.0 * yuv.x)),
	                          0.125 * (0.25 * sign2(yuv.yz) + round(8.0 * yuv.yz)));

	return mul(yuv_2_rgb, quantized);
}

float3 organize(float3 col) {
	float3x3 blowout = transpose(float3x3(1.87583893, 0.96308725, 0., 0.96308725, 1.17416107, 0., 0., 0., 0.5));
	float3 cent = float3(0.47968451,
	                     0.450743,
	                     0.45227517) + 0.2;

	float3 dir = mul(blowout, col - cent);
	float3 maxes = (step(float3(0.0, 0.0, 0.0), dir) - col) / dir;
	float amount = min(maxes.x, min(maxes.y, maxes.z));

	return col + dir * 0.5 * amount;
}

float4 mainImage(VertData v_in) : TARGET {
	float4 fragColor;
	float edgesize = 2.0 / min(iResolution.x, iResolution.y);
	float edge_modulate =
		smoothstep(30.0, 15.0, 0.4 * edge(v_in.uv, edgesize));
	float3 color = organize(color_quantize_yuv(image.Sample(textureSampler, v_in.uv).rgb));
	float3 line_color = float3(0.1, 0.1, 0.1);

	fragColor = float4(lerp(line_color, color, edge_modulate), 1.0);

	return fragColor;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
