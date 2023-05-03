// Mirror dimension
// https://www.shadertoy.com/view/dlSXDG
// Created by creikey in 2023-02-15
//
// Trying to be mirror dimension from doctor strange, I think needs more
// interesting line pattern
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)

sampler_state mirrorSampler {
	AddressU = Mirror;
	AddressV = Mirror;
};

#define iTime elapsed_time

void spinline(float2 uv, float2 line_dir, float2 line_origin, out float spinning_line, out float below_spinning_line) {
	float2 line_normal = float2(-line_dir.y, line_dir.x);
	spinning_line = clamp(1.0 - abs(dot(uv - line_origin, line_dir)) * 100.0, 0.0, 1.0);
	float2 from_origin = uv - line_origin;
	below_spinning_line = clamp(dot(line_normal, float2(-from_origin.y, from_origin.x)) * 100.0, 0.0, 1.0);
}

float4 mainImage(VertData v_in) : TARGET {
	float2 uv = v_in.uv;

	float below_spinning_line;
	float spinning_line;

	spinline(uv, float2(cos(iTime), sin(iTime)), float2(0.3, 0.4), spinning_line, below_spinning_line);
	uv += float2(0.01, 0.01) * spinning_line;
	uv += float2(-0.06, 0.01 + sin(iTime * 0.2) * 0.05) * below_spinning_line;

	spinline(uv, float2(cos(iTime * 0.3 + 0.5), sin(iTime * 0.3 + 0.5)), float2(0.5, 0.6), spinning_line, below_spinning_line);
	uv += float2(0.01, 0.01) * spinning_line;
	uv += float2(-0.015, 0.02 + sin(iTime * 0.1) * 0.04) * below_spinning_line;

	spinline(uv, float2(cos(-iTime * 0.1 + 0.5), sin(-iTime * 0.1 + 0.5)), float2(0.2, 0.8), spinning_line, below_spinning_line);
	uv += float2(0.01, 0.01) * spinning_line;
	uv += float2(-0.015, 0.02 + sin(iTime * 0.1 + 0.5) * 0.04) * below_spinning_line;

	spinline(uv, float2(cos(-iTime * 0.4 + 0.5), sin(-iTime * 0.4 + 0.5)), float2(0.9, 0.3), spinning_line, below_spinning_line);
	uv += float2(0.01, 0.01) * spinning_line;
	uv += float2(-0.015, 0.02 + cos(iTime * 0.1 + 0.5) * 0.04) * below_spinning_line;

	float3 col = image.Sample(mirrorSampler, uv).rgb;

	return float4(col, 1.0);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
