shader_type spatial;

render_mode unshaded, depth_draw_opaque, cull_disabled;

uniform sampler2D sprite; 

instance uniform float rotate_by = 0.0;

/**
 * Generate a transformation matrix.
 * This code comes from the Terrain3D project.
 */
mat3 rotation_matrix(vec3 axis, float angle) {
	float c = cos(angle);
	float s = sin(angle);
	float t = 1.0 - c;
	vec3 n = normalize(axis);
	float x = n.x;
	float y = n.y;
	float z = n.z;

	return mat3(
		vec3(t * x * x + c, t * x * y - z * s, t * x * z + y * s),
		vec3(t * x * y + z * s, t * y * y + c, t * y * z - x * s),
		vec3(t * x * z - y * s, t * y * z + x * s, t * z * z + c));
}

void vertex() {
	// Billboard Mode: Enabled (default Godot shader)
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
			
	// rotation along the Z axis
	// This is the added part
	vec3 orientation = vec3(0.0, 0.0, 1.0);
	// angle is a value between 0.0 and 1.0
	float angle = INSTANCE_CUSTOM.z;
	mat3 rotation = rotation_matrix(vec3(0.0, 0.0, 1.0), rotate_by);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(rotation);
	
	vec2 texture_size = vec2(textureSize(sprite, 0).xy);
	
	// Billboard Keep Scale: Enabled
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz) * texture_size.x / texture_size.y, 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment(){
	ALBEDO = texture(sprite, UV).xyz;
	ALPHA = texture(sprite, UV).w;
}