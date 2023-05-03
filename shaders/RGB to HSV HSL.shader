// RGB to HSV/HSL
// https://www.shadertoy.com/view/4dKcWK
// Created by tayloia in 2018-04-16
//
// Sandbox for RGB to HSV/HSL conversions and vice versa
//
// Things to notice:
// 1) There's a visible difference between changing the "V" in HSV and the "L" in HSL
// 2) The round-trip of HSV is slightly more accurate than HSL (but not worth considering in reality)
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

#define EPSILON 1e-10

float3 HUEtoRGB(in float hue) {
	// Hue [0..1] to RGB [0..1]
	// See http://www.chilliant.com/rgb2hsv.html
	float3 rgb = abs(hue * 6. - float3(3, 2, 4)) * float3(1, -1, -1) + float3(-1, 2, 2);

	return clamp(rgb, 0., 1.);
}

float3 RGBtoHCV(in float3 rgb) {
	// RGB [0..1] to Hue-Chroma-Value [0..1]
	// Based on work by Sam Hocevar and Emil Persson
	float4 p = (rgb.g < rgb.b) ? float4(rgb.bg, -1., 2. / 3.) : float4(rgb.gb, 0., -1. / 3.);
	float4 q = (rgb.r < p.x) ? float4(p.xyw, rgb.r) : float4(rgb.r, p.yzx);
	float c = q.x - min(q.w, q.y);
	float h = abs((q.w - q.y) / (6. * c + EPSILON) + q.z);

	return float3(h, c, q.x);
}

float3 HSVtoRGB(in float3 hsv) {
	// Hue-Saturation-Value [0..1] to RGB [0..1]
	float3 rgb = HUEtoRGB(hsv.x);

	return ((rgb - 1.) * hsv.y + 1.) * hsv.z;
}

float3 HSLtoRGB(in float3 hsl) {
	// Hue-Saturation-Lightness [0..1] to RGB [0..1]
	float3 rgb = HUEtoRGB(hsl.x);
	float c = (1. - abs(2. * hsl.z - 1.)) * hsl.y;

	return (rgb - 0.5) * c + hsl.z;
}

float3 RGBtoHSV(in float3 rgb) {
	// RGB [0..1] to Hue-Saturation-Value [0..1]
	float3 hcv = RGBtoHCV(rgb);
	float s = hcv.y / (hcv.z + EPSILON);

	return float3(hcv.x, s, hcv.z);
}

float3 RGBtoHSL(in float3 rgb) {
	// RGB [0..1] to Hue-Saturation-Lightness [0..1]
	float3 hcv = RGBtoHCV(rgb);
	float z = hcv.z - hcv.y * 0.5;
	float s = hcv.y / (1. - abs(z * 2. - 1.) + EPSILON);

	return float3(hcv.x, s, z);
}

// RGB

float3 image0(float3 rgb) {
	// Just return the raw image value
	return rgb;
}

float3 image1(float3 rgb) {
	// Return the greyscale of the image
	const float3 weights = float3(0.299, 0.587, 0.114);

	return dot(rgb, weights);
}

float3 image2(float3 rgb) {
	// Return the exaggerated hue of the image
	float hue = RGBtoHCV(rgb).x;

	return HUEtoRGB(hue);
}

// HSL

float3 image3(float3 rgb) {
	// Round-trip RGB->HSL->RGB with time-dependent hue shift
	float3 hsl = RGBtoHSL(rgb);
	hsl.x = frac(hsl.x + iTime * 0.15);

	return HSLtoRGB(hsl);
}

float3 image4(float3 rgb) {
	// Round-trip RGB->HSL->RGB with time-dependent lightness
	float3 hsl = RGBtoHSL(rgb);
	hsl.z = pow(hsl.z, sin(iTime) + 1.5);

	return HSLtoRGB(hsl);
}

float3 image5(float3 rgb) {
	// Round-trip RGB->HSL->RGB and display exaggerated errors
	float3 hsl = RGBtoHSL(rgb);

	return abs(rgb - HSLtoRGB(hsl)) * 10000000.;
}

// HSV

float3 image6(float3 rgb) {
	// Round-trip RGB->HSV->RGB with time-dependent lightness
	float3 hsv = RGBtoHSV(rgb);
	hsv.y = clamp(hsv.y * (1. + sin(iTime * 1.5)), 0., 1.);

	return HSVtoRGB(hsv);
}

float3 image7(float3 rgb) {
	// Round-trip RGB->HSV->RGB with time-dependent value
	float3 hsv = RGBtoHSV(rgb);
	hsv.z = pow(hsv.z, sin(iTime) + 1.5);

	return HSVtoRGB(hsv);
}

float3 image8(float3 rgb) {
	// Round-trip RGB->HSV->RGB and display exaggerated errors
	float3 hsv = RGBtoHSV(rgb);

	return abs(rgb - HSVtoRGB(hsv)) * 10000000.;
}

// sRGB

float3 SRGBtoRGB(float3 srgb) {
	// See http://chilliant.blogspot.co.uk/2012/08/srgb-approximations-for-hlsl.html
	// This is a better approximation than the common "pow(rgb, 2.2)"
	return pow(srgb, 2.1632601288);
}

float3 RGBtoSRGB(float3 rgb) {
	// This is a better approximation than the common "pow(rgb, 0.45454545)"
	return pow(rgb, 0.46226525728);
}

float3 iimage(int panel, float2 uv) {
	float3 rgb = SRGBtoRGB(image.Sample(textureSampler, uv).rgb);
	switch (panel) {
	case 0: return RGBtoSRGB(image0(rgb));
	case 1: return RGBtoSRGB(image1(rgb));
	case 2: return RGBtoSRGB(image2(rgb));
	case 3: return RGBtoSRGB(image3(rgb));
	case 4: return RGBtoSRGB(image4(rgb));
	case 5: return RGBtoSRGB(image5(rgb));
	case 6: return RGBtoSRGB(image6(rgb));
	case 7: return RGBtoSRGB(image7(rgb));
	case 8: return RGBtoSRGB(image8(rgb));
	}

	return float3(0, 0, 0);
}

float4 mainImage(VertData v_in) : TARGET {
	const float ROWS = 3.;
	const float COLUMNS = 3.;
	const float GAP = 0.05;
	// If ROWS=3 and COLUMNS=3 then the layout of the panels is:
	//
	// 	+---+---+---+
	// 	| 6 | 7 | 8 |
	// 	+---+---+---+
	// 	| 3 | 4 | 5 |
	// 	+---+---+---+
	// 	| 0 | 1 | 2 |
	// 	+---+---+---+
	//
	float3 srgb = 0.1;
	float2 uv = v_in.uv; // Normalized pixel coordinates (from 0 to 1)
	uv.x -= (1. - COLUMNS / ROWS) * 0.5; // Centre the panels according to the aspect ratio
	uv = uv * (ROWS + GAP) - GAP; // Add gaps between panels

	if ((uv.x >= 0.) && (uv.y >= 0.) && (uv.x < COLUMNS)) {
		// We're inside the main panel region
		int2 iuv = int2(uv);
		uv = frac(uv) * (1. + GAP);

		if (max(abs(uv.x), abs(uv.y)) < 1.) {
			// We're inside one of the panels
			int panel = iuv.x + iuv.y * int(COLUMNS);
			srgb = iimage(panel, uv);
		}
	}

	return float4(srgb, 1);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
