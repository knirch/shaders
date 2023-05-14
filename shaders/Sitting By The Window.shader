// Sitting By The Window
// https://www.shadertoy.com/view/slfSzS
// Created by Awayko_Wakee in 2021-07-10
//
// And dreaming of everything
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/
//
// Porting notes: Flipped the y coordinate before applying the raindroplets,
// otherwise they moved upwards.

// GLSL -> HLSL
#define length(v) sqrt(dot(v, v))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

// For reference, the default textureSampler inserted by OBS-ShaderFilter.
sampler_state textureSampler {
	Filter = Linear;
	AddressU = Border;
	AddressV = Border;
	BorderColor = 00000000;
};

// shader derived from Heartfelt - by Martijn Steinrucken aka BigWings - 2017
// https://www.shadertoy.com/view/ltffzl
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define S(a, b, t) smoothstep(a, b, t)
#define size 0.2

float3 N13(float p) {
	//  from DAVE HOSKINS
	float3 p3 = frac(float3(p, p, p) * float3(.1031, .11369, .13787));
	p3 += dot(p3, p3.yzx + 19.19);

	return frac(float3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

float4 N14(float t) {
	return frac(sin(t * float4(123., 1024., 1456., 264.)) * float4(6547., 345., 8799., 1564.));
}

float N(float t) {
	return frac(sin(t * 12345.564) * 7658.76);
}

float Saw(float b, float t) {
	return S(0., b, t) * S(1., b, t);
}

float2 Drops(float2 uv, float t) {
	float2 UV = uv;

	// DEFINE GRID
	uv.y += t * 0.8;
	float2 a = float2(6., 1.);
	float2 grid = a * 2.;
	float2 id = floor(uv * grid);

	// RANDOM SHIFT Y
	float colShift = N(id.x);
	uv.y += colShift;

	// DEFINE SPACES
	id = floor(uv * grid);
	float3 n = N13(id.x * 35.2 + id.y * 2376.1);
	float2 st = frac(uv * grid) - float2(.5, 0);

	// POSITION DROPS
	// clamp(2*x,0,2)+clamp(1-x*.5, -1.5, .5)+1.5-2
	float x = n.x - .5;

	float y = UV.y * 20.;

	float distort = sin(y + sin(y));
	x += distort * (.5 - abs(x)) * (n.z - .5);
	x *= .7;
	float ti = frac(t + n.z);
	y = (Saw(.85, ti) - .5) * .9 + .5;
	float2 p = float2(x, y);

	// DROPS
	float d = length((st - p) * a.yx);

	float dSize = size;

	float Drop = S(dSize, .0, d);

	float r = sqrt(S(1., y, st.y));
	float cd = abs(st.x - x);

	// TRAILS
	float trail = S((dSize * .5 + .03) * r, (dSize * .5 - .05) * r, cd);
	float trailFront = S(-.02, .02, st.y - y);
	trail *= trailFront;

	// DROPLETS
	y = UV.y;
	y += N(id.x);
	float trail2 = S(dSize * r, .0, cd);
	float droplets = max(0., (sin(y * (1. - y) * 120.) - st.y)) * trail2 * trailFront * n.z;
	y = frac(y * 10.) + (st.y - .5);
	float dd = length(st - float2(x, y));
	droplets = S(dSize * N(id.x), 0., dd);
	float m = Drop + droplets * r * trailFront;

	return float2(m, trail);
}

float StaticDrops(float2 uv, float t) {
	uv *= 30.;

	float2 id = floor(uv);
	uv = frac(uv) - .5;
	float3 n = N13(id.x * 107.45 + id.y * 3543.654);
	float2 p = (n.xy - .5) * 0.5;
	float d = length(uv - p);

	float fade = Saw(.025, frac(t + n.z));
	float c = S(size, 0., d) * frac(n.z * 10.) * fade;

	return c;
}

float2 Rain(float2 uv, float t) {
	float s = StaticDrops(uv, t);
	float2 r1 = Drops(uv, t);
	float2 r2 = Drops(uv * 1.8, t);

	float c = s + r1.x + r2.x;

	c = S(.3, 1., c);

	return float2(c, max(r1.y, r2.y));
}

float4 mainImage(VertData v_in) : TARGET {
	float2 fragCoord = v_in.uv * iResolution;

	float2 uv = (fragCoord.xy - .5 * iResolution.xy) / iResolution.y;
	float2 UV = v_in.uv;

	float T = iTime;

	float t = T * .2;

	float rainAmount = 0.8;

	v_in.uv = (v_in.uv - .5) * (.9) + .5;

	// knirch - IDK, but this fixed it
	uv = float2(uv.x, -uv.y);
	float2 c = Rain(uv, t);

	float2 e = float2(.001, 0.); // pixel offset
	float cx = Rain(uv + e, t).x;
	float cy = Rain(uv + e.yx, t).x;
	float2 n = float2(cx - c.x, cy - c.x); // normals

	// BLUR derived from existical https://www.shadertoy.com/view/Xltfzj
	float Pi = 6.28318530718; // Pi*2

	// GAUSSIAN BLUR SETTINGS {{{
	float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
	float Quality = 8.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
	float Size = 32.0; // BLUR SIZE (Radius)
	// GAUSSIAN BLUR SETTINGS }}}

	float2 Radius = Size / iResolution.xy;

	float3 col = image.Sample(textureSampler, v_in.uv).rgb;

	// Blur calculations
	for (float d = 0.0; d < Pi; d += Pi / Directions) {
		for (float i = 1.0 / Quality; i <= 1.0; i += 1.0 / Quality) {
			float3 tex = image.Sample(textureSampler, UV + n + float2(cos(d), sin(d)) * Radius * i).rgb;
			col += tex;
		}
	}

	col /= Quality * Directions - 0.0;

	float3 tex = image.Sample(textureSampler, UV + n).rgb;
	c.y = clamp(c.y, 0.0, 1.);

	col -= c.y;
	col += c.y * (tex + .6);

	return float4 (col, 1.);
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
