// Kuwahara Filter #01
// https://www.shadertoy.com/view/csVXzz
// Created by benjik42 in 2023-04-05
//
// Here is an implementation of Kuwahara Filter !
// Next step will be to implement a directional Kuwahara Filter
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

float4 mainImage(VertData v_in) : TARGET {
	float4 fragColor;
	float2 fragCoord = v_in.uv * iResolution;

	float2 uv = v_in.uv;

	int RADIUS = 5;
	float2 pos;
	float3 col;

	float4 coll = image.Sample(textureSampler, uv);
	float3 mean[4] = {float3(0., 0., 0.), float3(0., 0., 0.), float3(0., 0., 0.), float3(0., 0., 0.)};
	float3 sigma[4] = {float3(0., 0., 0.), float3(0., 0., 0.), float3(0., 0., 0.), float3(0., 0., 0.)};

	float2 offsets[4] = { float2(-RADIUS, -RADIUS), float2(-RADIUS, 0.), float2(0., -RADIUS), float2(0., 0.)};

	for (int i = 0; i < 4; i++) {

		for (int j = 0; j <= RADIUS; j++) {
			for (int k = 0; k <= RADIUS; k++) {
				pos = float2(j, k) + offsets[i];
				float2 uvpos = uv + pos / iResolution.xy;
				col = image.Sample(textureSampler, uvpos).xyz;

				mean[i] += col;
				sigma[i] += col * col;
			}
		}
	}

	float n = (float(RADIUS) + 1.) * (float(RADIUS) + 1.);
	float sigma_f;
	float min = 1.;

	for (int i = 0; i < 4; i++) {
		mean[i] /= n;
		sigma[i] = abs(sigma[i] / n - mean[i] * mean[i]);
		sigma_f = sigma[i].r + sigma[i].g + sigma[i].b;

		if (sigma_f < min) {
			min = sigma_f;
			col = mean[i];
		}
	}

	// float offset = (sin(iTime)+1.)/2.;
	// float side = floor(uv.r+offset);
	// col = lerp(float3(image.Sample(textureSampler, uv)),col,side);

	fragColor = float4(col, 1.); // Output to screen

	return fragColor;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
