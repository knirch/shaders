// Atkinson Dithering
// https://www.shadertoy.com/view/wttfRX
// Created by outofpaper in 2023-03-30
//
// Working towards Atkinson dithering
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define length(v) sqrt(dot(v, v))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)

uniform int lookupSize = 256;
uniform float errorCarry = 0.8;

float getGrayscale(float2 coords) {
	float2 uv = coords / iResolution.xy;
	float3 sourcePixel = image.Sample(textureSampler, uv).rgb;

	return length(sourcePixel * float3(0.7, 0.7, 0.0722));
}

float4 mainImage(VertData v_in) : TARGET {
	float4 fragColor;
	float2 fragCoord = v_in.uv * iResolution;

	int topGapY = int(iResolution.y - fragCoord.y);

	int cornerGapX = int((fragCoord.x < 10.0) ? fragCoord.x : iResolution.x - fragCoord.x);
	int cornerGapY = int((fragCoord.y < 10.0) ? fragCoord.y : iResolution.y - fragCoord.y);
	int cornerThreshhold = ((cornerGapX == 0) || (topGapY == 0)) ? 5 : 4;

	float xError = 0.0;

	for (int xLook = 0; xLook < lookupSize; xLook++) {
		float grayscale = getGrayscale(fragCoord.xy + float2(-lookupSize + xLook, 0));
		grayscale += xError;
		float bit = grayscale >= 0.5 ? 1.0 : 0.0;
		xError = (grayscale - bit) * errorCarry;
	}

	float yError = 0.0;

	for (int yLook = 0; yLook < lookupSize; yLook++) {
		float grayscale = getGrayscale(fragCoord.xy + float2(0, -lookupSize + yLook));
		grayscale += yError;
		float bit = grayscale >= 0.5 ? 1.0 : 0.0;
		yError = (grayscale - bit) * errorCarry;
	}

	float finalGrayscale = getGrayscale(fragCoord.xy);
	finalGrayscale += xError * 0.2 + yError * 0.2;
	float finalBit = finalGrayscale >= 0.5 ? 0.95 : 0.05;

	return float4(finalBit, finalBit, finalBit, 1);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
