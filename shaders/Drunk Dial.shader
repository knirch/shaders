// Drunk Dial
// https://www.shadertoy.com/view/MdSGRh
// Created by moskow23 in 2013-11-02
//
// CC BY-NC-SA 3.0 https://creativecommons.org/licenses/by-nc-sa/3.0/

// GLSL -> HLSL
#define mod(x, y) (x - y * floor(x / y))

// Shadertoy -> OBS-Shaderfilter
#define iResolution float4((uv_size - uv_offset) / uv_scale, uv_pixel_interval)
#define iTime elapsed_time

float4 mainImage(VertData v_in) : TARGET {
	float2 fragCoord = v_in.uv * iResolution;
	// Just playing around with shaders for my first time.
	// Pardon the unoptimized mess.
	// -Dan
	float drunk = sin(iTime * 2.) * 6.;
	float unitDrunk1 = (sin(iTime * 1.2) + 1.) / 2.;
	float unitDrunk2 = (sin(iTime * 1.8) + 1.) / 2.;

	float2 normalizedCoord = mod((fragCoord.xy + float2(0, drunk)) / iResolution.xy, 1.);
	normalizedCoord.x = pow(normalizedCoord.x, lerp(1.25, 0.85, unitDrunk1));
	normalizedCoord.y = pow(normalizedCoord.y, lerp(0.85, 1.25, unitDrunk2));

	float2 normalizedCoord2 = mod((fragCoord.xy + float2(drunk, 0)) / iResolution.xy, 1.);
	normalizedCoord2.x = pow(normalizedCoord2.x, lerp(0.95, 1.1, unitDrunk2));
	normalizedCoord2.y = pow(normalizedCoord2.y, lerp(1.1, 0.95, unitDrunk1));

	float2 normalizedCoord3 = fragCoord.xy / iResolution.xy;

	float4 color = image.Sample(textureSampler, normalizedCoord);
	float4 color2 = image.Sample(textureSampler, normalizedCoord2);
	float4 color3 = image.Sample(textureSampler, normalizedCoord3);

	// Mess with colors and test swizzling
	color.x = sqrt(color2.x);
	color2.x = sqrt(color2.x);

	float4 finalColor = lerp(lerp(color, color2, lerp(0.4, 0.6, unitDrunk1)), color3, 0.4);

	if (length(finalColor) > 1.4)
		finalColor.xy = lerp(finalColor.xy, normalizedCoord3, 0.5);
	else if (length(finalColor) < 0.4)
		finalColor.yz = lerp(finalColor.yz, normalizedCoord3, 0.5);

	return finalColor;
}

// Converted to OBS-Shaderfilter by Knirch and ChatGPT
// vim: ft=c:noai:ts=4:sw=4
