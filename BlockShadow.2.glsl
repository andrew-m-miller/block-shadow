#version 120

// BlockShadow pass 2: extrude the matte into a hard block shadow.

uniform sampler2D adsk_results_pass1;
uniform float adsk_result_w, adsk_result_h;

uniform float angle;         // degrees, 0 = right, counter-clockwise
uniform float shadowLength;  // pixels

// Upper bound on extrusion samples (one per pixel of length).
const int MAX_STEPS = 4096;

float sampleMatte(vec2 uv)
{
	// Treat anything outside the frame as empty so edges don't smear inward.
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
		return 0.0;
	return texture2D(adsk_results_pass1, uv).a;
}

void main(void)
{
	vec2 res = vec2(adsk_result_w, adsk_result_h);
	vec2 uv = gl_FragCoord.xy / res;

	// March back along the shadow direction; the shadow at this pixel is the
	// max of the matte anywhere between 0 and shadowLength pixels behind it.
	float rad = radians(angle);
	vec2 dirUV = vec2(cos(rad), sin(rad)) / res;
	float len = max(shadowLength, 0.0);
	int steps = int(ceil(len));

	float shadowA = 0.0;
	for (int i = 1; i < MAX_STEPS; i++) {
		if (i > steps || shadowA >= 1.0)
			break;
		float t = min(float(i), len);
		shadowA = max(shadowA, sampleMatte(uv - dirUV * t));
	}

	gl_FragColor = vec4(shadowA);
}
