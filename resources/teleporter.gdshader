shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 beam_color : source_color = vec4(0.15, 0.55, 1.0, 1.0);
uniform float intensity = 10.0;

// MUST match your CylinderMesh radius (before node scaling)
uniform float cylinder_radius = 0.5;

// thickness of the glowing “skin” on the sides (bigger = thicker)
uniform float skin_thickness = 0.15;

// Rim glow (helps visibility from the side)
uniform float rim_strength = 3.0;
uniform float rim_power = 2.0;

// Motion
uniform float scroll_speed = 1.5;
uniform float swirl_amount = 0.25;
uniform float swirl_speed  = 1.2;
uniform float noise_scale = 6.0;
uniform float noise_strength = 0.6;

// Optional top/bottom fade (set to 0.0 to disable)
uniform float end_fade = 0.0;

varying vec3 local_pos;

// cheap noise
float hash12(vec2 p){
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}
float noise2(vec2 p){
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	vec2 u = f*f*(3.0-2.0*f);
	return mix(a,b,u.x) + (c-a)*u.y*(1.0-u.x) + (d-b)*u.x*u.y;
}

void vertex() {
	local_pos = VERTEX; // local-space position
}

void fragment() {
	// r = 0 center, r = 1 surface
	float r = length(local_pos.xz) / max(cylinder_radius, 0.0001);

	// ✅ side "skin" mask: 0 inside, 1 near the surface
	float skin = smoothstep(1.0 - skin_thickness, 1.0, r);

	// angle around cylinder + height scroll
	float ang = atan(local_pos.z, local_pos.x); // -pi..pi
	float u = (ang / 6.28318) + 0.5;            // 0..1
	float v = UV.y + TIME * scroll_speed;

	u += sin(v * 6.28318 + TIME * swirl_speed) * swirl_amount;

	float n = noise2(vec2(u * noise_scale, v * noise_scale));
	float flicker = 1.0 + (n - 0.5) * 2.0 * noise_strength;

	// strong side rim
	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), rim_power);
	float rim = fresnel * rim_strength;

	// optional end fade
	float ends = 1.0;
	if (end_fade > 0.001) {
		float base_fade = smoothstep(0.0, end_fade, UV.y);
		float top_fade  = smoothstep(0.0, end_fade, 1.0 - UV.y);
		ends = base_fade * top_fade;
	}

	float glow = (skin * 1.2 + rim) * flicker * ends;

	ALBEDO   = beam_color.rgb * glow * intensity;
	EMISSION = beam_color.rgb * glow * intensity;
	ALPHA    = clamp(skin * ends, 0.0, 1.0);
}
