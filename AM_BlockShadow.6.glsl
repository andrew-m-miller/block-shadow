#version 120

// BlockShadow pass 6: distance to the silhouette (fill + shadow), vertical half.
//
// Combines the per-row distances from pass 5 into a Euclidean distance.
//
// Output R : distance to the silhouette, in display pixels

uniform sampler2D adsk_results_pass5;
uniform float adsk_result_w, adsk_result_h;

uniform int outlineMode;    // 0 = off, 1 = fill, 2 = silhouette, 3 = both
uniform float outlineWidth; // pixels

const int MAX_RADIUS = 1024;
const float FAR = 10000.0;

void main(void)
{
	bool shapeOutline = outlineMode == 2 || outlineMode == 3;
	if (!shapeOutline || outlineWidth <= 0.0) {
		gl_FragColor = vec4(FAR);
		return;
	}

	vec2 res = vec2(adsk_result_w, adsk_result_h);
	vec2 px = gl_FragCoord.xy;

	int radius = int(ceil(outlineWidth + 1.0));

	float d = FAR;
	for (int j = 0; j < 2 * MAX_RADIUS + 1; j++) {
		int i = j - radius;
		if (i > radius)
			break;
		vec2 uv = (px + vec2(0.0, float(i))) / res;
		if (uv.y < 0.0 || uv.y > 1.0)
			continue;

		float h = texture2D(adsk_results_pass5, uv).r;
		float dy = max(abs(float(i)) - 0.5, 0.0);
		if (h < FAR)
			d = min(d, sqrt(h * h + dy * dy));
	}

	gl_FragColor = vec4(d, 0.0, 0.0, 1.0);
}
