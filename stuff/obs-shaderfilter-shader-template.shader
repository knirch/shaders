//

uniform float4x4 ViewProj;
uniform texture2d image;

uniform float2 uv_offset;
uniform float2 uv_scale;
uniform float2 uv_pixel_interval;
uniform float2 uv_size;
uniform float rand_f;
uniform float rand_instance_f;
uniform float rand_activation_f;
uniform float elapsed_time;
uniform int loops;
uniform float local_time;

sampler_state textureSampler {
	Filter = Linear;
	AddressU = Border;
	AddressV = Border;
	BorderColor = 00000000;
};

struct VertData {
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
};

VertData mainTransform(VertData v_in) {
	VertData vert_out;
	vert_out.pos = mul(float4(v_in.pos.xyz, 1.0), ViewProj);
	vert_out.uv = v_in.uv * uv_scale + uv_offset;

	return vert_out;
}

// Shader code is inserted here
//
// float4 mainImage(VertData v_in) : TARGET
// {
// 	return image.Sample(textureSampler, v_in.uv);
// }

technique Draw
{
	pass
	{
		vertex_shader = mainTransform(v_in);
		pixel_shader = mainImage(v_in);
	}
}
