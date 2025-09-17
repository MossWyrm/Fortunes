shader_type canvas_item;

uniform float wave_strength : hint_range(0.0, 0.1) = 0.02;
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;
uniform float wave_frequency : hint_range(1.0, 20.0) = 8.0;
uniform float ghost_opacity : hint_range(0.0, 1.0) = 0.7;
uniform vec4 ghost_tint : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;
uniform float pulse_strength : hint_range(0.0, 0.5) = 0.2;

// Atlas texture support
uniform bool using_atlas = false;
uniform vec2 sprite_size;
uniform vec2 atlas_size;

// New texture atlas support
uniform bool new_using_atlas = false;
uniform vec2 new_sprite_size;
uniform vec2 new_atlas_size;
uniform vec2 new_atlas_offset;

// Ripple transition parameters
uniform sampler2D new_texture : filter_linear_mipmap;
uniform float ripple_progress : hint_range(0.0, 1.0) = 0.0;
uniform float ripple_width : hint_range(0.01, 0.2) = 0.05;
uniform bool transition_active = false;
uniform bool start_invisible = false;

// Padding parameters - now handled in GDScript sizing
uniform float texture_scale : hint_range(0.1, 1.0) = 0.77; // How much of the TextureRect the actual texture occupies

vec2 getPixelPosInTile(vec2 uv, vec2 sprite_sz, vec2 atlas_sz) {
    float exactPosX = floor(uv.x * atlas_sz.x);
    float exactPosY = floor(uv.y * atlas_sz.y);
    float relativePosX = mod(exactPosX, sprite_sz.x);
    float relativePosY = mod(exactPosY, sprite_sz.y);
    return vec2(relativePosX / sprite_sz.x, relativePosY / sprite_sz.y);
}

vec2 mapToAtlasUV(vec2 local_uv, vec2 sprite_sz, vec2 atlas_sz, vec2 offset) {
    // Clamp local_uv to 0-1 range first
    local_uv = clamp(local_uv, vec2(0.0), vec2(1.0));

    // Map local UV (0-1) to sprite size within atlas
    vec2 sprite_uv = local_uv * (sprite_sz / atlas_sz);

    // Add the offset (which should be in UV coordinates 0-1)
    return sprite_uv + offset;
}

void vertex() {
    // No vertex scaling - breathing space handled by GDScript sizing
}

void fragment() {
    // Handle atlas UV mapping first
    vec2 base_uv;
    if (using_atlas) {
        base_uv = getPixelPosInTile(UV, sprite_size, atlas_size);
    } else {
        base_uv = UV;
    }

    // Map UV to the center portion of the TextureRect (texture_scale determines how much)
    vec2 center = vec2(0.5, 0.5);
    vec2 original_uv = center + (base_uv - center) / texture_scale;

    // Calculate wave distortion - but fade it out during transition
    float wave_fade = 1.0;
    if (transition_active) {
        wave_fade = 1.0 - smoothstep(0.0, 0.8, ripple_progress);
    }

    float wave_x = sin(original_uv.y * wave_frequency + TIME * wave_speed) * wave_strength * wave_fade;
    float wave_y = sin(original_uv.x * wave_frequency * 0.7 + TIME * wave_speed * 0.8) * wave_strength * 0.5 * wave_fade;

    // Apply wave distortion
    vec2 distorted_uv = original_uv + vec2(wave_x, wave_y);

    // Default to transparent
    vec4 final_color = vec4(0.0, 0.0, 0.0, 0.0);

    // Only render if we're within the valid texture bounds (0-1)
    if (distorted_uv.x >= 0.0 && distorted_uv.x <= 1.0 &&
        distorted_uv.y >= 0.0 && distorted_uv.y <= 1.0) {

        // Convert back to base UV coordinates for texture sampling
        vec2 sample_uv;
        if (using_atlas) {
            // Map back to atlas coordinates
            vec2 distorted_base_uv = center + (distorted_uv - center);
            vec2 atlas_uv = UV;
            vec2 uv_offset = distorted_base_uv - base_uv;
            sample_uv = atlas_uv + uv_offset * (sprite_size / atlas_size);
        } else {
            sample_uv = distorted_uv;
        }

        // Calculate sample UV for new texture
        vec2 new_sample_uv;
        if (new_using_atlas) {
            // Ensure we're sampling within the new texture's bounds
            vec2 clamped_distorted_uv = clamp(distorted_uv, vec2(0.0), vec2(1.0));
            new_sample_uv = mapToAtlasUV(clamped_distorted_uv, new_sprite_size, new_atlas_size, new_atlas_offset);

            // Double check that the final UV is within atlas bounds
            new_sample_uv = clamp(new_sample_uv, vec2(0.0), vec2(1.0));
        } else {
            new_sample_uv = distorted_uv;
        }

        // Sample current texture (TEXTURE)
        vec4 current_color = texture(TEXTURE, sample_uv);

        // If start_invisible is true, treat current as transparent
        if (start_invisible) {
            current_color = vec4(0.0, 0.0, 0.0, 0.0);
        }

        // Sample new texture
        vec4 new_color = texture(new_texture, new_sample_uv);

        // Start with current color
        vec4 result_color = current_color;

        if (transition_active) {
            // Calculate distance from center for ripple
            vec2 ripple_center = vec2(0.5, 0.5);
            float dist_from_center = distance(original_uv, ripple_center);

            // Create ripple wave
            float ripple_distance = ripple_progress * 1.5;
            float ripple_front = ripple_distance;
            float ripple_back = ripple_distance - ripple_width;

            if (dist_from_center < ripple_back) {
                result_color = new_color;
            } else if (dist_from_center < ripple_front) {
                float ripple_intensity = (dist_from_center - ripple_back) / ripple_width;

                if (start_invisible) {
                    float reveal_intensity = 1.0 - ripple_intensity;
                    result_color = new_color * reveal_intensity;
                } else {
                    result_color = mix(new_color, current_color, ripple_intensity);
                }

                float edge_intensity = sin((1.0 - ripple_intensity) * 3.14159);
                result_color.rgb += vec3(0.3, 0.5, 1.0) * edge_intensity * 0.8;
            } else {
                result_color = current_color;
            }
        }

        // Only apply effects if pixel has some alpha
        if (result_color.a > 0.0) {
            float pulse = sin(TIME * pulse_speed) * pulse_strength * wave_fade + (1.0 - pulse_strength * wave_fade);

            float ghostly_effect = ghost_opacity;
            vec4 tint_effect = ghost_tint;

            if (transition_active && ripple_progress > 0.8) {
                float fade_to_normal = smoothstep(0.8, 1.0, ripple_progress);
                ghostly_effect = mix(ghost_opacity, 1.0, fade_to_normal);
                tint_effect = mix(ghost_tint, vec4(1.0, 1.0, 1.0, 1.0), fade_to_normal);
            }

            final_color = result_color * tint_effect;
            final_color.a = result_color.a * ghostly_effect * pulse;

            float edge_glow = 1.0 - min(min(original_uv.x, 1.0 - original_uv.x), min(original_uv.y, 1.0 - original_uv.y)) * 4.0;
            edge_glow = smoothstep(0.0, 1.0, edge_glow);
            final_color.rgb += ghost_tint.rgb * edge_glow * 0.3 * pulse * wave_fade;
        }
    }

    COLOR = final_color;
}