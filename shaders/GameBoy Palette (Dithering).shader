// GameBoy Palette (Dithering)
// https://www.shadertoy.com/view/ttlfzj
// Created by hobbes in 2020-08-12
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)

#define gb_colors float4x3(float3(15., 56., 15.) / 255., float3(48., 98., 48.) / 255., float3(139., 172., 15.) / 255., float3(155., 188., 15.) / 255.)

uniform float size = 128.0; // Pixelated resolution x-component
uniform float threshold = 0.006; // Threshold for dithering (0.0045 found to be optimal)

float3 closest_gb(float3 color) {
	int best_i = 0;
	float best_d = 2.;

	for (int i = 0; i < 4; i++) {
		float d = distance(gb_colors[i], color);

		if (d < best_d) {
			best_d = d;
			best_i = i;
		}
	}

	return gb_colors[best_i];
}

float2x3 gb_2_closest(float3 color) {
	int first_i = 0;
	float first_d = 2.;

	int second_i = 0;
	float second_d = 2.;

	for (int i = 0; i < 4; i++) {
		float d = distance(gb_colors[i], color);

		if (d <= first_d) {
			second_i = first_i;
			second_d = first_d;
			first_i = i;
			first_d = d;
		} else if (d <= second_d) {
			second_i = i;
			second_d = d;
		}
	}

	if (first_i < second_i)
		return float2x3(gb_colors[first_i], gb_colors[second_i]);
	else
		return float2x3(gb_colors[second_i], gb_colors[first_i]);
}

bool needs_dither(float3 color) {
	float first_d = 2.;
	float second_d = 2.;

	for (int i = 0; i < 4; i++) {
		float d = distance(gb_colors[i], color);

		if (d <= first_d) {
			second_d = first_d;
			first_d = d;
		} else if (d <= second_d) {
			second_d = d;
		}
	}

	return abs(first_d - second_d) <= threshold;
}

float2 get_tile_sample(float2 coords, float2 res) {
	return floor(coords * res / 2.) * 2. / res;
}

float4 mainImage( VertData v_in ) : TARGET {
	float2 fragCoord = v_in.uv * iResolution;

	float2x2 dither_2 = float2x2(0., 1., 1., 0.);
	float2 resolution = float2(size, iResolution.y / iResolution.x * size);
	float2 uv = floor(fragCoord / iResolution.xy * resolution) / resolution;

	float2 tileSample = get_tile_sample(uv, resolution);
	float3 sampleColor = image.Sample(textureSampler, tileSample).xyz;

	if (needs_dither(sampleColor)) {
		int2 ti = int2(floor((uv - tileSample) * resolution * 2.));

		return float4(gb_2_closest(sampleColor)[int(dither_2[ti.x][ti.y])], 1.);
	} else {
		return float4(closest_gb(image.Sample(textureSampler, uv).xyz), 1.0);
	}
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
