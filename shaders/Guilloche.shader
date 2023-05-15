// Guilloche
// https://www.shadertoy.com/view/tsSSDc
// Created by rafaelcastrocouto in 2019-04-12
//
// Trying to implement a Guilloche texture dithering effect like in this article:
// https://blog.spoongraphics.co.uk/tutorials/create-realistic-money-effect-photoshop
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define mod(x, y) (x - y * floor(x / y))

// GLSL -> HLSL;  float2x2 * float2 does not work, have to use mul(float2x2, float2)
// // Something like this doesn't work:
// // const float angle = PI/levels;
// // const float3 color = float3(0.05,0.1,-0.15);

/// this is a good time to figure out what I need to document etc..
// idea for my shader conversions; ability to scan through the shaders and download the originals. should be fairly simple as I always have the url in the top

// autoconversion-downloader-kickstart; provide url; download and generate the template I always create before getting to work

#define PI 3.14159265359
#define levels 3.0
#define angle float(PI / levels)

// const float levels = 3.0;
// const float angle = PI/levels;
uniform float spacing = 0.01;
uniform float frequency = 30.0;
uniform float height = 0.003;
uniform float width = 0.015;
uniform float alias = 0.002;
uniform float bright = 1.2;
uniform float dist = 0.2;
uniform float3 color = {0.05, 0.1, -0.15};

float2x2 rotate2d(float cangle) {
	return float2x2(cos(cangle), -sin(cangle),
	                sin(cangle), cos(cangle));
}

float4 mainImage(VertData v_in) : TARGET {
	float result = 0.0;
	// input texture from channel 0
	float4 tex = image.Sample(textureSampler, v_in.uv);
	// float t;
	float t = float(tex.x);

	// diagonal waves
	for (float i = 0.0; i < levels; i++) {
		// new uv coordinate
		float2 nuv = mul(rotate2d(angle + angle * i), v_in.uv);
		// calculate wave
		float wave = sin(nuv.x * frequency) * height;
		float x = (spacing / 2.0) + wave;
		float y = mod(nuv.y, spacing);
		// wave lines
		float lline = width * (1.0 - (t * bright) - (i * dist));
		float waves = smoothstep(lline, lline + alias, abs(x - y));
		// save the result for the next wave
		result += waves;
	}

	result /= levels;
	// increase contrast
	result = smoothstep(0.6, 1.0, result);
	// add some color
	// float3 colored = float3(result+color,result+color,result+color);
	float3 colored = float3(result + color);

	// output to screen
	return float4(colored, 1.0);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
