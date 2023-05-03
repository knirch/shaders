#define i 1.8 * cos(6. * iTime)
#define j 3.2 * sin(6. * iTime)
float lum(vec4 c) {
	return dot(c.rgb, vec3(0.3, 0.59, 0.11));
}

float cau = sqrt(2.), civ = 250.;
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;

	vec2 imageIncrement = vec2(1.0, 1.0) / iResolution.xy;

	float t00 = lum(texture(iChannel0, uv + imageIncrement * vec2(-i, -i)));
	float t10 = lum(texture(iChannel0, uv + imageIncrement * vec2( 0.0, -i)));
	float t20 = lum(texture(iChannel0, uv + imageIncrement * vec2( j, -i)));
	float t01 = lum(texture(iChannel0, uv + imageIncrement * vec2(-i, 0.0)));
	float t21 = lum(texture(iChannel0, uv + imageIncrement * vec2( j, 0.0)));
	float t02 = lum(texture(iChannel0, uv + imageIncrement * vec2(-i, j)));
	float t12 = lum(texture(iChannel0, uv + imageIncrement * vec2( 0.0, j)));
	float t22 = lum(texture(iChannel0, uv + imageIncrement * vec2( j, j)));

	vec2 grad;
	grad.x = t00 + 2.0 * t01 + t02 - t20 - 2.0 * t21 - t22;
	grad.y = t00 + 2.0 * t10 + t20 - t02 - 2.0 * t12 - t22;

	vec3 c = vec3(0);
	vec2 alpha = uv * 2. - 1.;
	float beta = length(alpha / 2.);
	beta = pow(beta, 3.);
	beta *= abs(sin(2. * iTime)) * 23.;
	beta /= cau;
	vec3 af = vec3(0);
	float ci = (1. / civ) * beta;
	af.x = texture(iChannel0, uv + vec2(-2. / cau) * ci).r;
	af.y = texture(iChannel0, uv + vec2(-1., 3.) / cau * ci).g;
	af.z = texture(iChannel0, uv + vec2(i, 0) * ci).b;
	c = af;
	float len = length(grad);

	if (sin(2. * iTime) > 0.4 && sin(2. * iTime) < 0.8)
		fragColor = pow(vec4( len * len * sin(8.4), len * len * sin(2.8), len * len * sin(3.2), len * len * sin(5.6)), texture(iChannel0, uv));
	else
		fragColor = c.rgbr;
}
