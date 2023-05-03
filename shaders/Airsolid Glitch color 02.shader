// Airsolid Glitch color 02
// https://www.shadertoy.com/view/ttdXD8
// Created by airsolid in 2020-02-05
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

uniform texture2d bitmap = "./noise_down.png";

sampler_state noiseSampler {
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Repeat;
	AddressV = Repeat;
	BorderColor = 99000000;
};

// The textureSampler defined in OBS-Shaderfilter uses 'Border' which produces
// undesirable black boxes, clamping to edge looks much nicer.
sampler_state imageSampler {
	AddressU = D3DTADDRESS_CLAMP;
	AddressV = D3DTADDRESS_CLAMP;
};

float rand(float n) {
	return frac(sin(n) * 43758.5453123);
}

float noise(float p) {
	float fl = floor(p);
	float fc = frac(p);

	return lerp(rand(fl), rand(fl + 1.0), fc);
}

float blockyNoise(float2 uv, float threshold, float scale, float seed) {
	float scroll = floor(iTime + sin(11.0 * iTime) + sin(iTime)) * 0.77;
	float2 noiseUV = uv.yy / scale + scroll;
	float noise2 = bitmap.Sample(noiseSampler, noiseUV).r;

	float id = floor(noise2 * 20.0);
	id = noise(id + seed) - 0.5;

	if (abs(id) > threshold)
		id = 0.0;

	return id;
}

float4 mainImage(VertData v_in ) : TARGET {
	float4 fragColor;
	float2 fragCoord = v_in.uv * iResolution;

	float rgbIntensity = 0.1 + 0.1 * sin(iTime * 3.7);
	float displaceIntensity = 0.2 + 0.3 * pow(sin(iTime * 1.2), 5.0);
	float interlaceIntensity = 0.01;
	float dropoutIntensity = 0.1;

	float2 uv = fragCoord / iResolution.xy;
	// float2 uv = v_in.uv;

	float displace = blockyNoise(uv + float2(uv.y, 0.0), displaceIntensity, 25.0, 66.6);
	displace *= blockyNoise(uv.yx + float2(0.0, uv.x), displaceIntensity, 111.0, 13.7);

	uv.x += displace;

	float2 offs = 0.1 * float2(blockyNoise(uv.xy + float2(uv.y, 0.0), rgbIntensity, 65.0, 341.0), 0.0);

	float colr = image.Sample(imageSampler, uv - offs).r;
	float colg = image.Sample(imageSampler, uv).g;
	float colb = image.Sample(imageSampler, uv + offs).b;

	float lne = frac(fragCoord.y / 3.0);
	float3 mask = float3(3.0, 0.0, 0.0);

	if (lne > 0.333)
		mask = float3(0.0, 3.0, 0.0);

	if (lne > 0.666)
		mask = float3(0.0, 0.0, 3.0);

	float maskNoise = blockyNoise(uv, interlaceIntensity, 90.0, iTime) * max(displace, offs.x);

	maskNoise = 1.0 - maskNoise;

	if (maskNoise == 1.0)
		mask = float3(1., 1., 1.);

	float dropout = blockyNoise(uv, dropoutIntensity, 11.0, iTime) * blockyNoise(uv.yx, dropoutIntensity, 90.0, iTime);
	mask *= (1.0 - 5.0 * dropout);

	fragColor = float4(mask * float3(colr, colg, colb), 1.0);

	return fragColor;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
