// Godot 4.3, Forward+ or Mobile
shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;

uniform float strength = 0.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec4 screen = texture(screen_texture, SCREEN_UV);

	vec2 uvCenter = SCREEN_UV - vec2(0.5, 0.5);
	uvCenter = uvCenter * 2.0 * strength;
	float dist = sqrt(pow(uvCenter.x, 2) + pow(uvCenter.y, 2));

	ALBEDO.rgb = vec3(0.5, 0.0, 0.0);
	ALPHA = dist;
}