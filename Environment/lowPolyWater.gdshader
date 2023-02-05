shader_type spatial;

render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 out_color : source_color = vec4(0.0, 1.0, 1.0, 0.99);
uniform float amount : hint_range(0.0, 1.5) = 0.8;
uniform float beer_factor = 0.3;

float generateOffset(float x, float z, float val1, float val2, float time) {
	float speed = 0.5;
	
	float radiansX = ((mod(x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;
	
	return amount * 0.25 * (sin(radiansZ) + cos(radiansX));
}

vec3 applyDistortion(vec3 vertex, float time) {
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);
	return vertex + vec3(xd, yd, zd);
}

void vertex() {
	VERTEX = applyDistortion(VERTEX, TIME * 0.1);
}

void fragment() {
	vec4 n_out3p0 = out_color;
	vec3 n_out2p0;
	{
		float base = vec3(n_out3p0.xyz).x;
		float blend = vec3(n_out3p0.xyz).x;
		if (base < 0.5) {
			n_out2p0.x = 2.0 * base * blend;
		} else {
			n_out2p0.x = 1.0 - 2.0 * (1.0 - blend) * (1.0 - base);
		}
	}
	{
		float base = vec3(n_out3p0.xyz).y;
		float blend = vec3(n_out3p0.xyz).y;
		if (base < 0.5) {
			n_out2p0.y = 2.0 * base * blend;
		} else {
			n_out2p0.y = 1.0 - 2.0 * (1.0 - blend) * (1.0 - base);
		}
	}
	{
		float base = vec3(n_out3p0.xyz).z;
		float blend = vec3(n_out3p0.xyz).z;
		if (base < 0.5) {
			n_out2p0.z = 2.0 * base * blend;
		} else {
			n_out2p0.z = 1.0 - 2.0 * (1.0 - blend) * (1.0 - base);
		}
	}
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = 0.0;
	SPECULAR = 0.1;
	ROUGHNESS = 0.1;
	ALBEDO = n_out2p0;
	ALPHA = out_color.w;
}