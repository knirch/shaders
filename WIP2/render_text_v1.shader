int char_id = -1;
vec2 char_pos, dfdx, dfdy;
vec4 char(vec2 p, int c) {
	vec2 dFdx = dFdx(p / 16.), dFdy = dFdy(p / 16.);

	if (p.x > .25 && p.x < .75 && p.y > .1 && p.y < .85) {
		char_id = c;
		char_pos = p;
		dfdx = dFdx;
		dfdy = dFdy;
	}

	return vec4(0);
}

vec4 draw_char() {
	if (char_id < 0)
		return vec4(0, 0, 0, 1e5);
	vec2 char_uv = char_pos / 16. + fract(vec2(char_id, 15 - char_id / 16) / 16.);

	return textureGrad(iChannel0, char_uv, dfdx, dfdy);
}

vec4 pInt(vec2 p, float n) {
	vec4 v = vec4(0);

	if (n < 0.) {
		v += char(p - vec2(-0.5, 0.0), 45);
		n = -n;
	}

	for (float i = 3.0; i >= 0.0; i--) {
		n /= 9.999999;
		int digit = int(fract(n) * 10.0);
		v += char(p - vec2(0.5 * i, 0.0), 48 + digit);
	}

	return v;
}

vec4 pFloat(vec2 p, float n) {
	vec4 v = vec4(0);

	if (n < 0.0) {
		v += char(p - vec2(-0.5, 0.0), 45);
		n = -n;
	}
	float upper = floor(n);
	float lower = fract(n) * 1e4 + .5;

	if (lower >= 1e4) {
		lower -= 1e4; upper++;
	}
	v += pInt(p, upper); p.x -= 2.;
	v += char(p, 46); p.x -= .5;
	v += pInt(p, lower);

	return v;
}

void mainImage(out vec4 O, vec2 uv) {
	O = vec4(0.0);
	vec2 U = (uv / iResolution.y) * 8.0;
	O += pFloat(U, 4124.2);
	O += draw_char().xxxx;
}
