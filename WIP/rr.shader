const float EPSILON = 1e-10;

vec3 HUEtoRGB(in float hue) {
	// Hue [0..1] to RGB [0..1]
	// See http://www.chilliant.com/rgb2hsv.html
	vec3 rgb = abs(hue * 6. - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);

	return clamp(rgb, 0., 1.);
}

vec3 RGBtoHCV(in vec3 rgb) {
	// RGB [0..1] to Hue-Chroma-Value [0..1]
	// Based on work by Sam Hocevar and Emil Persson
	vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1., 2. / 3.) : vec4(rgb.gb, 0., -1. / 3.);
	vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
	float c = q.x - min(q.w, q.y);
	float h = abs((q.w - q.y) / (6. * c + EPSILON) + q.z);

	return vec3(h, c, q.x);
}

vec3 HSVtoRGB(in vec3 hsv) {
	// Hue-Saturation-Value [0..1] to RGB [0..1]
	vec3 rgb = HUEtoRGB(hsv.x);

	return ((rgb - 1.) * hsv.y + 1.) * hsv.z;
}

vec3 HSLtoRGB(in vec3 hsl) {
	// Hue-Saturation-Lightness [0..1] to RGB [0..1]
	vec3 rgb = HUEtoRGB(hsl.x);
	float c = (1. - abs(2. * hsl.z - 1.)) * hsl.y;

	return (rgb - 0.5) * c + hsl.z;
}

vec3 RGBtoHSV(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Value [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float s = hcv.y / (hcv.z + EPSILON);

	return vec3(hcv.x, s, hcv.z);
}

vec3 RGBtoHSL(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Lightness [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float z = hcv.z - hcv.y * 0.5;
	float s = hcv.y / (1. - abs(z * 2. - 1.) + EPSILON);

	return vec3(hcv.x, s, z);
}

// RGB

vec3 image0(vec3 rgb) {
	// Just return the raw image value
	return rgb;
}

vec3 image1(vec3 rgb) {
	// Return the greyscale of the image
	const vec3 weights = vec3(0.299, 0.587, 0.114);

	return vec3(dot(rgb, weights));
}

vec3 image2(vec3 rgb) {
	// Return the exaggerated hue of the image
	float hue = RGBtoHCV(rgb).x;

	return HUEtoRGB(hue);
}

// HSL

vec3 image3(vec3 rgb) {
	// Round-trip RGB->HSL->RGB with time-dependent hue shift
	vec3 hsl = RGBtoHSL(rgb);
	hsl.x = fract(hsl.x + iTime * 0.15);

	return HSLtoRGB(hsl);
}

vec3 image4(vec3 rgb) {
	// Round-trip RGB->HSL->RGB with time-dependent lightness
	vec3 hsl = RGBtoHSL(rgb);
	hsl.z = pow(hsl.z, sin(iTime) + 1.5);

	return HSLtoRGB(hsl);
}

vec3 image5(vec3 rgb) {
	// Round-trip RGB->HSL->RGB and display exaggerated errors
	vec3 hsl = RGBtoHSL(rgb);

	return abs(rgb - HSLtoRGB(hsl)) * 10000000.;
}

// HSV

vec3 image6(vec3 rgb) {
	// Round-trip RGB->HSV->RGB with time-dependent lightness
	vec3 hsv = RGBtoHSV(rgb);
	hsv.y = clamp(hsv.y * (1. + sin(iTime * 1.5)), 0., 1.);

	return HSVtoRGB(hsv);
}

vec3 image7(vec3 rgb) {
	// Round-trip RGB->HSV->RGB with time-dependent value
	vec3 hsv = RGBtoHSV(rgb);
	hsv.z = pow(hsv.z, sin(iTime) + 1.5);

	return HSVtoRGB(hsv);
}

vec3 image8(vec3 rgb) {
	// Round-trip RGB->HSV->RGB and display exaggerated errors
	vec3 hsv = RGBtoHSV(rgb);

	return abs(rgb - HSVtoRGB(hsv)) * 10000000.;
}

// sRGB

vec3 SRGBtoRGB(vec3 srgb) {
	// See http://chilliant.blogspot.co.uk/2012/08/srgb-approximations-for-hlsl.html
	// This is a better approximation than the common "pow(rgb, 2.2)"
	return pow(srgb, vec3(2.1632601288));
}

vec3 RGBtoSRGB(vec3 rgb) {
	// This is a better approximation than the common "pow(rgb, 0.45454545)"
	return pow(rgb, vec3(0.46226525728));
}

vec3 image(int panel, vec2 uv) {
	vec3 rgb = SRGBtoRGB(texture(iChannel0, uv).rgb);
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

	return vec3(0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
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
	vec3 srgb = vec3(0.1);
	vec2 uv = fragCoord / iResolution.xy; // Normalized pixel coordinates (from 0 to 1)
	uv.x -= (1. - COLUMNS / ROWS) * 0.5; // Centre the panels according to the aspect ratio
	uv = uv * (ROWS + GAP) - GAP; // Add gaps between panels

	if ((uv.x >= 0.) && (uv.y >= 0.) && (uv.x < COLUMNS)) {
		// We're inside the main panel region
		ivec2 iuv = ivec2(uv);
		uv = fract(uv) * (1. + GAP);

		if (max(abs(uv.x), abs(uv.y)) < 1.) {
			// We're inside one of the panels
			int panel = iuv.x + iuv.y * int(COLUMNS);
			srgb = image(panel, uv);
		}
	}

	// Output to screen
	fragColor = vec4(srgb, 1);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
