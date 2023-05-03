// 20200323_集中線
// https://www.shadertoy.com/view/wsfcDM
// Created by FMS_Cat in 2020-03-22
//
// ババーン
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define atan(y, x) atan2(x, y)
#define mod(x, y) (x - y * floor(x / y))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

#define ANIMATE 2.0
#define INV_ANIMATE_FREQ 0.05
#define RADIUS 1.3
#define FREQ 10.0
#define LENGTH 2.0
#define SOFTNESS 0.1
#define WEIRDNESS 0.1

#define ASPECT_AWAR 0

uniform bool use_aspect_ratio = true;

#define lofi(x, d) floor(x / d) * d

float hash(float2 v) {
	return frac(sin(dot(v, float2(89.44, 19.36))) * 22189.22);
}

float iHash(float2 v, float2 r) {
	float4 h = float4(hash(float2(floor(v * r + float2(0.0, 0.0)) / r)),
	                  hash(float2(floor(v * r + float2(0.0, 1.0)) / r)),
	                  hash(float2(floor(v * r + float2(1.0, 0.0)) / r)),
	                  hash(float2(floor(v * r + float2(1.0, 1.0)) / r))
	);
	float2 ip = float2(smoothstep(float2(0., 0.), float2(1., 1.), mod(v * r, 1.0)));

	return lerp(lerp(h.x, h.y, ip.y), lerp(h.z, h.w, ip.y), ip.x);
}

float noise(float2 v) {
	float sum = 0.0;

	for (int i = 1; i < 7; i++)
		sum += iHash(v + i, 2.0 * pow(2.0, float(i))) / pow(2.0, float(i));

	return sum;
}

float4 mainImage( VertData v_in ) : TARGET {
	float2 uv;
	float2 fragCoord = v_in.uv * iResolution;

	if (use_aspect_ratio)
		uv = (fragCoord.xy * 2.0 - iResolution.xy) / iResolution.xy;
	else
		uv = (fragCoord.xy * 2.0 - iResolution.xy) / iResolution.y;

	float2 puv = float2(WEIRDNESS * length(uv) + ANIMATE * lofi(iTime, INV_ANIMATE_FREQ),
	                    FREQ * atan(uv.y, uv.x)
	);
	float value = noise(puv);
	value = length(uv) - RADIUS - LENGTH * (value - 0.5);
	value = smoothstep(-SOFTNESS, SOFTNESS, value);

	float4 tex = image.Sample(textureSampler, fragCoord.xy / iResolution.xy);

	return float4(lerp(tex.xyz, float3(1., 1., 1.), value), 1.);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
