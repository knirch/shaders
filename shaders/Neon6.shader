// Neon6
// https://www.shadertoy.com/view/Nl33D2
// Created by Jzscwhat in 2021-11-12
//
// Forked from Neon5 (https://www.shadertoy.com/view/7sGXDt)
// Simple 2D cel shading effect based on sobel filter
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

#define imageIncrement float2(float2(1., 1.) / iResolution.xy)

#define j float(3.2 * sin(6. * iTime))
#define i float(1.8 * cos(6. * iTime))

float lum(float4 c) {
	return float(dot(c.rgb, float3(0.3, 0.59, 0.11)));
}

float4 mainImage(VertData v_in) : TARGET {
	float4 fragColor;
	float2 fragCoord = v_in.uv * iResolution;
	float2 uv = fragCoord.xy / iResolution.xy;

	if (sin(2. * iTime) > 0.4 && sin(2. * iTime) < 0.8) {
		float t00 = lum(image.Sample(textureSampler, uv + imageIncrement * float2(-i, -i)));
		float t10 = lum(image.Sample(textureSampler, uv + imageIncrement * float2(0., -i)));
		float t20 = lum(image.Sample(textureSampler, uv + imageIncrement * float2( j, -i)));
		float t01 = lum(image.Sample(textureSampler, uv + imageIncrement * float2(-i, 0.)));
		float t21 = lum(image.Sample(textureSampler, uv + imageIncrement * float2( j, 0.)));
		float t02 = lum(image.Sample(textureSampler, uv + imageIncrement * float2(-i, j)));
		float t12 = lum(image.Sample(textureSampler, uv + imageIncrement * float2( 0., j)));
		float t22 = lum(image.Sample(textureSampler, uv + imageIncrement * float2( j, j)));

		float2 grad = float2(t00 + 2. * t01 + t02 - t20 - 2. * t21 - t22,
		                     t00 + 2. * t10 + t20 - t02 - 2. * t12 - t22
		);
		float len = dot(grad, grad);
		fragColor.rgb = pow(float3(len * sin(8.4), len * sin(2.8), len * sin(3.2)), image.Sample(textureSampler, uv).rgb);
	} else {
		const float CAU = sqrt(2.);
		const float CIV = 250.;
		const float2 UV_OFFSET_1 = float2(-2. / CAU, -2. / CAU);
		const float2 UV_OFFSET_2 = float2(-1., 3.) / CAU;

		float ci = pow(length((uv * 2. - 1.) / 2.), 3.);
		ci *= abs(sin(2. * iTime)) * 23. / CAU;
		ci /= CIV;

		fragColor.r = image.Sample(textureSampler, uv + UV_OFFSET_1 * ci).r;
		fragColor.g = image.Sample(textureSampler, uv + UV_OFFSET_2 * ci).g;
		fragColor.b = image.Sample(textureSampler, uv + float2(i, 0.) * ci).b;

		// const float cau = sqrt(2.);
		// float2 alpha = uv * 2. - 1.;
		// float beta = length(alpha / 2.);
		// beta = pow(beta, 3.);
		// beta *= abs(sin(2. * iTime)) * 23.;
		// beta /= cau;
		// float civ = 250.;
		// float ci = (1. / civ) * beta;
		// fragColor.r = image.Sample(textureSampler, uv + float2(-2. / cau, -2. / cau) * ci).r;
		// fragColor.g = image.Sample(textureSampler, uv + float2(-1., 3.) / cau * ci).g;
		// fragColor.b = image.Sample(textureSampler, uv + float2(i, 0.) * ci).b;
	}

	return float4(fragColor.rgb, 1.);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
