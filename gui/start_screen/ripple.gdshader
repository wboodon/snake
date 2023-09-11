shader_type canvas_item;
uniform float speed = 3.0;
uniform float width = 10.0;
uniform float height = 1.0;

void fragment() {
	/*
	//works for speed 2
	if(mod(-speed * TIME + 0.5 * UV.x, speed) < 0.25 * speed){
		float bounce = sin(PI * (4.0 * speed * TIME - 2.0 * UV.x - .5)) + 1.0;
		float offset = 0.5 * height * TEXTURE_PIXEL_SIZE.y * bounce;
		COLOR = texture(TEXTURE, UV + vec2(0.0, offset));
	}
	*/
	
	if(mod(TIME * width * speed - UV.x, 2.0) < width){
		float bounce = sin(2.0 * PI * (speed * TIME - UV.x / width - .25)) + 1.0;
		float offset = 0.5 * height * TEXTURE_PIXEL_SIZE.y * bounce;
		COLOR = texture(TEXTURE, UV + vec2(0.0, offset));
		//COLOR.a *= UV.x;
	}
}
