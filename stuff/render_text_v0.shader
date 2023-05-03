int char_id = -1;
vec2 char_pos, dfdx, dfdy;
vec4 char(vec2 p, int c) {
	vec2 dFdx = dFdx(p / 16.), dFdy = dFdy(p / 16.);

	if (p.x > .25 && p.x < .75 && p.y > .1 && p.y < .85)
		char_id = c, char_pos = p, dfdx = dFdx, dfdy = dFdy;

	return vec4(0);
}

vec4 draw_char() {
	int c = char_id; vec2 p = char_pos;

	return c < 0
	? vec4(0, 0, 0, 1e5)
	: textureGrad( iChannel0, p / 16. + fract( vec2(c, 15 - c / 16) / 16. ),
	               dfdx, dfdy );
}

vec4 pInt(vec2 p, float n) {
	vec4 v = vec4(0);

	if (n < 0.)
		v += char(p - vec2(-.5, 0), 45),
		n = -n;

	for (float i = 3.; i >= 0.; i--)
		n /= 9.999999,
		v += char(p - .5 * vec2(i, 0), 48 + int(fract(n) * 10.));

	return v;
}

vec4 pFloat(vec2 p, float n) {
	vec4 v = vec4(0);

	if (n < 0.) v += char(p - vec2(-.5, 0), 45), n = -n;
	float upper = floor(n);
	float lower = fract(n) * 1e4 + .5; // mla fix for rounding lost decimals

	if (lower >= 1e4) {
		lower -= 1e4; upper++;
	}
	v += pInt(p, upper); p.x -= 2.;
	v += char(p, 46); p.x -= .5;
	v += pInt(p, lower);

	return v;
}

void mainImage(out vec4 O, vec2 uv) {
	O -= O;
	vec2 U;
	U = (uv / iResolution.y) * 8.;
	O += pFloat(U, 4124.2);
	O += draw_char().xxxx;
}
