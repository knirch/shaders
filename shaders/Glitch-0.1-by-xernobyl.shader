// Glitch 0.1
// https://www.shadertoy.com/view/MlXXRB
// Created by xernobyl in 2015-07-22
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define mod(x, y) (x - y * floor(x / y))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

float rand(float2 co) {return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);}

sampler_state clampSampler {
	AddressU = D3DTADDRESS_CLAMP;
	AddressV = D3DTADDRESS_CLAMP;
};

float4 mainImage( VertData v_in ) : TARGET {
	float4 fragColor = float4(1., 1., 1., 1.);
	float2 fragCoord = v_in.uv * iResolution;
	float2 uv = fragCoord.xy / iResolution.xy;

	if (any(mod(iTime, 2.0) > 1.9)) // interlaced wave
		uv.x += cos(iTime * 10.0 + uv.y * 1000.0) * 0.01;

	if (any(mod(iTime, 4.0) > 3.0)) // pixelation
		uv = floor(uv * 32.0) / 32.0;

	if (any(mod(iTime, 5.0) > 3.75)) // shuffle-glitch
		uv += 1.0 / 64.0 * (2.0 * float2(rand(floor(uv * 32.) + float2(32.05, 236.)), rand(floor(uv.y * 32.) + float2(-62.05, -36.))) - 1.0);

	fragColor = image.Sample(clampSampler, uv);

	if (rand(float2(iTime, iTime)) > 0.90) // grayscale
		fragColor = dot(float3(fragColor.rgb), float3(0.25, 0.5, 0.25));

	// noise
	fragColor.rgb += 0.25 * float3(rand(iTime + fragCoord / float2(-213, 5.53)), rand(iTime - fragCoord / float2(213, -5.53)), rand(iTime + fragCoord / float2(213, 5.53))) - 0.125;

	return fragColor;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
