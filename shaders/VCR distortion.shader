// VCR distortion
// https://www.shadertoy.com/view/ldjGzV
// Created by ryk in 1391359899
//
// An attempt at making vcr style tape degradation.
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define mod(x, y) (x - y * floor(x / y))

// Shadertoy -> OBS-Shaderfilter
#define iTime elapsed_time

sampler_state noiseSampler {
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Repeat;
	AddressV = Repeat;
	BorderColor = 99000000;
};

uniform texture2d bitmap = "./gray_noise_medium.png";

float noise(float2 p) {
	float s = bitmap.Sample(noiseSampler, float2(1., 2. * cos(iTime)) * iTime * 8. + p * 1.).x;
	s *= s;

	return s;
}

float onOff(float a, float b, float c) {
	return step(c, sin(iTime + a * cos(iTime * b)));
}

float ramp(float y, float start, float end) {
	float inside = step(start, y) - step(end, y);
	float fact = (y - start) / (end - start) * inside;

	return (1. - fact) * inside;

}

float stripes(float2 uv) {
	float noi = noise(uv * float2(0.5, 1.) + float2(1., 3.));

	return ramp(mod(uv.y * 4. + iTime / 2. + sin(iTime + sin(iTime * 0.63)), 1.), 0.5, 0.6) * noi;
}

float3 getVideo(float2 uv) {
	float2 look = uv;
	float window = 1. / (1. + 20. * (look.y - mod(iTime / 4., 1.)) * (look.y - mod(iTime / 4., 1.)));
	look.x = look.x + sin(look.y * 10. + iTime) / 50. * onOff(4., 4., .3) * (1. + cos(iTime * 80.)) * window;
	float vShift = 0.4 * onOff(2., 3., .9) * (sin(iTime) * sin(iTime * 20.) +
	                                          (0.5 + 0.1 * sin(iTime * 200.) * cos(iTime)));
	look.y = mod(look.y + vShift, 1.);
	float3 video = float3(image.Sample(textureSampler, look).rgb);

	return video;
}

float2 screenDistort(float2 uv) {
	uv -= float2(.5, .5);
	uv = uv * 1.2 * (1. / 1.2 + 2. * uv.x * uv.x * uv.y * uv.y);
	uv += float2(.5, .5);

	return uv;
}

float4 mainImage(VertData v_in) : TARGET {
	float2 uv = screenDistort(v_in.uv);
	float3 video = getVideo(uv);
	float vigAmt = 3. + .3 * sin(iTime + 5. * cos(iTime * 5.));
	float vignette = (1. - vigAmt * (uv.y - .5) * (uv.y - .5)) * (1. - vigAmt * (uv.x - .5) * (uv.x - .5));

	video += stripes(uv);
	video += noise(uv * 2.) / 2.;
	video *= vignette;
	video *= (12. + mod(uv.y * 30. + iTime, 1.)) / 13.;

	return float4(video, 1.0);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
