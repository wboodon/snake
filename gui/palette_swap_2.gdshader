shader_type canvas_item;

uniform sampler2D palette: filter_nearest;
uniform sampler2D screen_texture: hint_screen_texture;
uniform float baseline_alpha = .1;
uniform bool invert = false;

void fragment() {
	vec3 foreground_color = texture(palette, vec2(.75, .5)).rgb;
	vec3 background_color = texture(palette, vec2(.25, .5)).rgb;
	if(!invert){
		COLOR = vec4(mix(foreground_color, background_color, texture(screen_texture, SCREEN_UV).r), 1.0);
	}else {
		COLOR = vec4(mix(foreground_color, background_color, 1.0 - texture(screen_texture, SCREEN_UV).r), 1.0);
	}
	
}
