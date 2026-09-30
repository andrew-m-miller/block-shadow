#version 120

// BlockShadow Matchbox
// Extrudes the matte along an angle to build a solid "block" style drop shadow,
// then comps the fill (colour or front) over it.
//
// Output RGB   : fill over shadow, premultiplied
// Output Alpha : combined fill + shadow matte

uniform sampler2D front;
uniform sampler2D matte;
uniform float adsk_result_w, adsk_result_h;

uniform float angle;         // degrees, 0 = right, counter-clockwise
uniform float shadowLength;  // pixels
uniform vec3 fillColor;
uniform vec3 shadowColor;
uniform bool useFront;
uniform bool frontPremultiplied;

// Upper bound on extrusion samples (one per pixel of length).
const int MAX_STEPS = 4096;

float sampleMatte(vec2 uv)
{
	// Treat anything outside the frame as empty so edges don't smear inward.
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
		return 0.0;
	return clamp(texture2D(matte, uv).r, 0.0, 1.0);
}

void main(void)
{
	vec2 res = vec2(adsk_result_w, adsk_result_h);
	vec2 uv = gl_FragCoord.xy / res;

	float fillA = sampleMatte(uv);

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

	// A premultiplied Front already carries the matte, so don't apply it twice.
	vec3 fillPremult;
	if (useFront && frontPremultiplied)
		fillPremult = texture2D(front, uv).rgb;
	else
		fillPremult = (useFront ? texture2D(front, uv).rgb : fillColor) * fillA;

	vec3 shadowPremult = shadowColor * shadowA;

	vec3 rgb = fillPremult + shadowPremult * (1.0 - fillA);
	float alpha = fillA + shadowA * (1.0 - fillA);

	gl_FragColor = vec4(rgb, alpha);
}
