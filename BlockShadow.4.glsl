#version 120

// BlockShadow pass 4: vertical gaussian blur of the shadow matte, then comp
// the fill over the shadow.

uniform sampler2D adsk_results_pass1;  // rgb = premultiplied fill, a = fill matte
uniform sampler2D adsk_results_pass3;  // horizontally blurred shadow matte
uniform float adsk_result_w, adsk_result_h;

uniform float softness;  // gaussian sigma in pixels
uniform vec3 shadowColor;
uniform float shadowOpacity;  // 0 = invisible, 1 = solid

// Upper bound on kernel half-width in pixels.
const int MAX_RADIUS = 1024;

void main(void)
{
	vec2 res = vec2(adsk_result_w, adsk_result_h);
	vec2 uv = gl_FragCoord.xy / res;

	float sigma = max(softness, 0.0);
	float shadowA = texture2D(adsk_results_pass3, uv).r;

	if (sigma >= 0.01) {
		int radius = int(ceil(sigma * 3.0));
		float k = -0.5 / (sigma * sigma);
		vec2 texel = vec2(0.0, 1.0 / res.y);

		float total = 1.0;
		for (int i = 1; i < MAX_RADIUS; i++) {
			if (i > radius)
				break;
			float y = float(i);
			float w = exp(y * y * k);
			shadowA += w * (texture2D(adsk_results_pass3, uv + texel * y).r
			              + texture2D(adsk_results_pass3, uv - texel * y).r);
			total += 2.0 * w;
		}
		shadowA /= total;
	}
	shadowA = clamp(shadowA, 0.0, 1.0) * clamp(shadowOpacity, 0.0, 1.0);

	vec4 fill = texture2D(adsk_results_pass1, uv);
	float fillA = fill.a;

	vec3 rgb = fill.rgb + shadowColor * shadowA * (1.0 - fillA);
	float alpha = fillA + shadowA * (1.0 - fillA);

	gl_FragColor = vec4(rgb, alpha);
}
