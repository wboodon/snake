shader_type canvas_item;

uniform sampler2D palette: filter_nearest;
uniform sampler2D screen_texture: hint_screen_texture;
uniform float grid_size = .25;
const vec2 resolution = vec2(160.0, 144.0);
uniform bool palette_swap = true;
uniform bool blur = true;
uniform bool dot_matrix = true;

void fragment() {
	vec4 text = texture(screen_texture, SCREEN_UV);
	if (palette_swap) { text = texture(palette, texture(screen_texture, SCREEN_UV).rg); }
	
	if (blur) {
		float dist_x = fract(SCREEN_UV.x * resolution.x);
		vec3 color_x;
		if(dist_x > .5){
			color_x = mix(texture(screen_texture, vec2(SCREEN_UV.x + SCREEN_PIXEL_SIZE.x, SCREEN_UV.y)).rgb, text.rgb, (1.0 - dist_x));
		} else {
			color_x = mix(texture(screen_texture, vec2(SCREEN_UV.x - SCREEN_PIXEL_SIZE.x, SCREEN_UV.y)).rgb, text.rgb, (dist_x));
		}
		float dist_y = fract(SCREEN_UV.y * resolution.y);
		vec3 color_y;
		if(dist_y > .5){
			color_y = mix(texture(screen_texture, vec2(SCREEN_UV.x, SCREEN_UV.y + SCREEN_PIXEL_SIZE.y)).rgb, text.rgb, (1.0 - dist_y));
		} else {
			color_y = mix(texture(screen_texture, vec2(SCREEN_UV.x, SCREEN_UV.y - SCREEN_PIXEL_SIZE.y)).rgb, text.rgb, (dist_y));
		}
		text.rgb = mix(color_x, color_y, 0.5);
		
	}
	
	if (dot_matrix) {
		//float scanlines = 0.5;
		//scanlines = smoothstep(grid_size, grid_size + 0.5, abs(sin(SCREEN_UV.y * (resolution.y * 3.14159265))));
		//text.rgb = mix(text.rgb, text.rgb * vec3(scanlines), 0.1);
		//vec3 matrix_color = mix(texture(palette, vec2(.5)).rgb, texture(palette, vec2(0.0)).rgb, -.5);
		vec3 matrix_color = texture(palette, vec2(.5)).rgb;
		//float matrix = abs(sin(SCREEN_UV.y * resolution.y * PI)) + abs(sin(SCREEN_UV.x * resolution.x * PI));
		//matrix = clamp(matrix, 0.0, 1.0);
		//text.rgb = mix(matrix_color, text.rgb, matrix);
		
		float matrix_x = clamp(2.5 * abs(sin(SCREEN_UV.x * (resolution.x * PI))), 0.5, 1.0);
		float matrix_y = clamp(2.5 * abs(sin(SCREEN_UV.y * (resolution.y * PI))), 0.5, 1.0);
		float matrix = clamp(matrix_x * matrix_y, 0.5, 1.0);
		//if(fract(SCREEN_UV.y * resolution.y) < .25){
		text.rgb = mix(matrix_color, text.rgb, matrix);
		//text.rgb = mix(matrix_color, text.rgb, matrix_y);
		//}
		//if(fract(SCREEN_UV.x * resolution.x) < .25){
		//	text.rgb = mix(text.rgb, matrix_color, 2.0 * abs(cos(SCREEN_UV.x * (resolution.x * PI))));
		//}
		
	}	
	COLOR = text;
}

/*
uniform float size = 64.0; // dots size | using int is ok
uniform vec4 color : source_color;

void fragment() {
	vec2 ratio = vec2(1.0, TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y); // make sure the dots are going to be 1:1
	vec2 pixelated_uv = floor(SCREEN_UV * size * ratio) / (size * ratio); // pixelates the UV, first multiply with size so it can be rounded to integer then divide it with the same value so your computer can see it and multiply with ratio to fix stretching
	float dots = length(fract(SCREEN_UV * size * ratio) - vec2(0.5)) * 2.0; // fracts the UV to make it loop, substract it by half then turn it into circle (using length) and finally multiply with 2 for smaller circle
	dots = (1.0 - dots) * 10.0; // invert the dot then make it look hard so soft circle is no more
	dots = clamp(dots, 0.0, 1.0); // limit the value to 1.0, otherwise it would add your pixel's brightness instead of being a border (this is because some of it's value is above 1.0)
	COLOR = mix(color, texture(screen_texture, pixelated_uv), dots); // mix the dots with the texture
}
*/