#version 120

// BlockShadow pass 3: horizontal gaussian blur of the shadow matte.

uniform sampler2D adsk_results_pass2;
uniform float adsk_result_w, adsk_result_h;

uniform float softness;  // gaussian sigma in pixels

// Upper bound on kernel half-width in pixels.
const int MAX_RADIUS = 1024;

void main(void)
{
	vec2 res = vec2(adsk_result_w, adsk_result_h);
	vec2 uv = gl_FragCoord.xy / res;

	float sigma = max(softness, 0.0);
	if (sigma < 0.01) {
		gl_FragColor = texture2D(adsk_results_pass2, uv);
		return;
	}

	int radius = int(ceil(sigma * 3.0));
	float k = -0.5 / (sigma * sigma);
	vec2 texel = vec2(1.0 / res.x, 0.0);

	float sum = texture2D(adsk_results_pass2, uv).r;
	float total = 1.0;
	for (int i = 1; i < MAX_RADIUS; i++) {
		if (i > radius)
			break;
		float x = float(i);
		float w = exp(x * x * k);
		sum += w * (texture2D(adsk_results_pass2, uv + texel * x).r
		          + texture2D(adsk_results_pass2, uv - texel * x).r);
		total += 2.0 * w;
	}

	gl_FragColor = vec4(sum / total);
}
