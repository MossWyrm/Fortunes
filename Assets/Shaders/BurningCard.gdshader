shader_type canvas_item;
render_mode unshaded;

uniform bool using_atlas;
uniform vec2 sprite_size;
uniform vec2 atlas_size;

uniform sampler2D noise_texture: hint_default_black, repeat_enable;
uniform float burn_amount: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec4 burn_color: source_color = vec4(0.8, 0.4, 0.2, 1.0);
uniform float distortion_edge: hint_range(0.0, 1.0, 0.01) = 0.05;
uniform float warp_factor: hint_range(0.0, 1.0, 0.01) = 0.3;

vec2 getPixelPosInTile(vec2 uv) { // 0.0 - 1.0
    float exactPosX = floor(uv.x * atlas_size.x); // pixels from left
    float exactPosY = floor(uv.y * atlas_size.y); // pixels from top
    float relativePosX = mod(exactPosX, sprite_size.x); // pixels from left of sprite
    float relativePosY = mod(exactPosY, sprite_size.y); // pixels from right of sprite
    return vec2(relativePosX / sprite_size.x, relativePosY / sprite_size.y);
}

void fragment() {
	vec2 uv;
	if (using_atlas) {
		uv = getPixelPosInTile(UV);
	} else {
		uv = UV;
	}
	float burn_pixel = (((texture(noise_texture, uv).r)*0.8)+0.11 );
	float mask = smoothstep(burn_amount -0.2, burn_amount , burn_pixel);
	float distortion = smoothstep(burn_amount -0.5, burn_amount + distortion_edge, burn_pixel);
	float transition = pow(distortion, 20.0);
	float warp = 1.0 - warp_factor + pow(distortion, 2.0) * warp_factor;
	vec4 color = texture(TEXTURE, UV* warp).rgba;
	COLOR = vec4(mix(color * (burn_color*4.0), color, transition) * mask);
}
