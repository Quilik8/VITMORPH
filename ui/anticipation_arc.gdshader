shader_type canvas_item;
render_mode unshaded;
uniform float fraction : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	if (UV.x > fraction) {
		discard;
	}
}
