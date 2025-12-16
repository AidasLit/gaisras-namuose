shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform vec4 lens_color : source_color = vec4(0.03, 0.06, 0.14, 1.0);
uniform float lens_alpha = 0.35;

uniform vec4 light_color : source_color = vec4(0.15, 0.55, 1.0, 1.0);
uniform float light_intensity = 14.0;   // raise if needed (10–30)

uniform float spin_speed = 2.0;
uniform float wedge_width = 0.8;        // radians (0.4 tight, 1.2 wide)
uniform float wedge_softness = 0.35;

uniform float pulse_speed = 7.0;
uniform float pulse_strength = 0.25;

uniform float rim_strength = 2.0;
uniform float rim_power = 2.0;

varying vec3 local_pos;

float ang_dist(float a, float b) {
	float d = abs(a - b);
	return min(d, 6.2831853 - d);
}

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	// 🔁 Angle around Y axis (upright siren)
	float ang = atan(local_pos.x, local_pos.z); // -pi..pi
	if (ang < 0.0) ang += 6.2831853;

	float center = fract(TIME * spin_speed) * 6.2831853;
	float d = ang_dist(ang, center);

	// Spinning wedge mask
	float wedge = 1.0 - smoothstep(
		wedge_width,
		wedge_width * (1.0 + wedge_softness),
		d
	);

	// Pulse
	float pulse = 1.0 - pulse_strength +
		(sin(TIME * pulse_speed) * 0.5 + 0.5) * pulse_strength;

	// Rim glow (helps visibility from the side)
	float fresnel = pow(
		1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0),
		rim_power
	);
	float rim = fresnel * rim_strength;

	float light_mask = clamp(wedge * pulse + rim * 0.25, 0.0, 10.0);

	// ✅ Visible even without Glow
	vec3 light_rgb = light_color.rgb * light_mask;

	ALBEDO = lens_color.rgb + light_rgb * 0.35;  // painted light
	EMISSION = light_rgb * light_intensity;      // glow if Glow enabled
	ALPHA = lens_alpha;
}
