// pixilartifier
// https://www.shadertoy.com/view/dlXSD4
// Created by MadMath123 in 2023-01-30
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)

uniform float colStepDiff = 4.0;

float3 getPos(float2 uv) {
	return floor(image.Sample(textureSampler, floor(uv * iResolution.xy / colStepDiff) * colStepDiff / iResolution.xy).rgb * 8.) / 8.;
}

float3 colorize(float3 col) {
	float avgCol = (col.r + col.g + col.b) / 3.;

	if (avgCol < .2) col.b += .1;

	if (avgCol > .8) col.g += .1;

	if (abs(col.r - col.g) > .2 && abs(col.g / col.b - 1.) > 1.) col.r = col.g + .2 * sign(col.r - col.g);

	if (abs(col.b - col.g) > .2 && abs(col.g / col.r - 1.) > 1.) col.b = col.g + .2 * sign(col.b - col.g);

	return col * .45 + .25;
}

float3 getCol(float2 uv) {
	float3 col = getPos(uv);
	float3 stepFactor = float3(colStepDiff * 2. / iResolution.x, colStepDiff * 2. / iResolution.y, 0.);
	float3 colU = getPos(uv + stepFactor.zy);
	float3 colD = getPos(uv - stepFactor.zy);
	float3 colR = getPos(uv + stepFactor.xz);
	float3 colL = getPos(uv - stepFactor.xz);
	float3 avgCol = (colU + colR + colD + colL) / 4.;
	float rDiff = abs(col.r - avgCol.r);
	float gDiff = abs(col.g - avgCol.g);
	float bDiff = abs(col.b - avgCol.b);

	if ((rDiff < .3 ? 1 : 0) + (gDiff < .3 ? 1 : 0) + (bDiff < .3 ? 1 : 0) == 1) {
		if (rDiff < .3) col.r = (col.g + col.b) / 3.;

		if (gDiff < .3) col.g = (col.b + col.r) / 3.;

		if (bDiff < .3) col.b = (col.g + col.r) / 3.;
	}

	return floor((colorize(col) * 6. - colorize(colU) - colorize(colD) - colorize(colR) - colorize(colL)) / 2. * 32.) / 32.;
}

float4 mainImage( VertData v_in ) : TARGET {
	float2 fragCoord = v_in.uv * iResolution;

	return float4(getCol(fragCoord.xy / iResolution.xy), 1.);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
