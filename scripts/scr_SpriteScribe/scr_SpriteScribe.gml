#macro	SPRITESCRIBE_VERSION							"1.0"
#macro	SPRITESCRIBE_DEFAULT_FONT_H_SCALE				1/string_width("#")
#macro	SPRITESCRIBE_DEFAULT_FONT_V_SCALE				1/string_height("#")
#macro	SPRITESCRIBE_LUMINANCE_GAMMA_CORRECTION			true
														
#macro	SPRITESCRIBE_DEBUG_SURFACES						false
#macro	SPRITESCRIBE_CHARS								["@","#","W","$","9","8","7","6","5","4","3","2","1","0","?","!","a","b","c",";",":","+","=","-",",",".","_"," "]

show_debug_message($"[SpriteScribe] Welcome to SpriteScribe {SPRITESCRIBE_VERSION} by manta ray (credits: buffer_getpixel script by YellowAfterlife)");

global.spritescribe_draw_cache = {};

function sprite_to_ascii(_sprite, _image, _xscale, _yscale, _angle, _color, _alpha) {
	var _time = current_time;
	
	var _key = string($"{sprite_get_name(_sprite)}|{floor(_image)}");
	var _w = sprite_get_width(_sprite) * _xscale;
	var _h = sprite_get_height(_sprite) * _yscale;
	
	var _surf = surface_create(_w, _h);
	surface_set_target(_surf);
	draw_clear_alpha(c_black, 0);
	var _xoffset = sprite_get_xoffset(_sprite) * _xscale;
	var _yoffset = sprite_get_yoffset(_sprite) * _yscale;
	draw_sprite_ext(_sprite, floor(_image), _xoffset, _yoffset, _xscale, _yscale, _angle, _color, _alpha);
	
	variable_struct_set(global.spritescribe_draw_cache, _key, {
		width: _w,
		height: _h,
		xscale: _xscale,
		yscale: _yscale,
		chars: [],
		color: [],
		alpha: [],
		luminance: [],
	});
	
	surface_reset_target();
	var _buffer = buffer_getpixel_begin(_surf);
	if (SPRITESCRIBE_DEBUG_SURFACES)			surface_save(_surf, string($"surface_debug_{sprite_get_name(_sprite)}_{floor(_image)}.png"));
	surface_free(_surf);
		
	for (var _row=0; _row<_h; _row++) {
		global.spritescribe_draw_cache[$ _key].chars[_row] = array_create(_w);
		global.spritescribe_draw_cache[$ _key].color[_row] = array_create(_w);
		global.spritescribe_draw_cache[$ _key].alpha[_row] = array_create(_w);
		global.spritescribe_draw_cache[$ _key].luminance[_row] = array_create(_w);
			
		for (var _col=0; _col<_w; _col++) {
			var _pixel = buffer_getpixel_ext(_buffer, _col, _row);
			var _pixel_alpha = (_pixel >> 24) & 255;
			var _pixel_blue = (_pixel >> 16) & 255;
			var _pixel_green = (_pixel >> 8) & 255;
			var _pixel_red = _pixel & 255;
			var _output_color = make_color_rgb(_pixel_red, _pixel_green, _pixel_blue);
			global.spritescribe_draw_cache[$ _key].color[_row][_col] = _output_color;
			global.spritescribe_draw_cache[$ _key].alpha[_row][_col] = _pixel_alpha/255;

			var _lum = 0.299 * _pixel_red/255 + 0.587 * _pixel_green/255 + 0.114 * _pixel_blue/255;
			if (SPRITESCRIBE_LUMINANCE_GAMMA_CORRECTION)	_lum = power(_lum, 1/2.2);
			global.spritescribe_draw_cache[$ _key].luminance[_row][_col] = _lum;
				
			var _char_idx = round((array_length(SPRITESCRIBE_CHARS)-1) * (1-_lum));
			var _char = SPRITESCRIBE_CHARS[_char_idx];
			global.spritescribe_draw_cache[$ _key].chars[_row][_col] = _char;
		}			
	}
	buffer_delete(_buffer);
	
	_time = (current_time - _time) / 1000;
	show_debug_message($"[SpriteScribe]: Processed {sprite_get_name(_sprite)} frame {floor(_image)} in {string_format(_time, 8, 4)} seconds (w={_w}, h={_h})");
}

///@function		draw_sprite_ascii_ext(_sprite, _image, _x, _y, _font_scale_h, _font_scale_v, _angle, _color, _alpha, [_font_h_spacing], [_font_v_spacing])
///@description		draws a sprite in ASCII art using the currently set font
///@return			{type}		|description|
function draw_sprite_ascii_ext(_sprite, _image, _x, _y, _font_scale_h, _font_scale_v, _angle, _color, _alpha, _font_h_spacing=0, _font_v_spacing=0) {
	live_auto_call;
	
	var _key = string($"{sprite_get_name(_sprite)}|{floor(_image)}");
	if (!variable_struct_exists(global.spritescribe_draw_cache, _key)) {
		throw(string($"[SpriteScribe] ERROR: sprite {sprite_get_name(_sprite)} image {floor(_image)} is not preprocessed. Process it first with sprite_to_ascii."));
	}
	else {
		var _w = global.spritescribe_draw_cache[$ _key].width;
		var _h = global.spritescribe_draw_cache[$ _key].height;
		var _font_w = string_width("#") * _font_scale_h;
		var _font_h = string_height("#") * _font_scale_v;
	
	
		var _xoffset = sprite_get_xoffset(_sprite) * global.spritescribe_draw_cache[$ _key].xscale * _font_w;
		var _yoffset = sprite_get_yoffset(_sprite) * global.spritescribe_draw_cache[$ _key].yscale * _font_h;
		var _pos_x = _x - _xoffset;
		var _pos_y = _y - _yoffset;
		var _initial_x = _x;
		var _initial_y = _y;
		
		for (var _row=0; _row<_h; _row++) {
			for (var _col=0; _col<_w; _col++) {
				var _char_color = global.spritescribe_draw_cache[$ _key].color[_row][_col];
				var _char_alpha = global.spritescribe_draw_cache[$ _key].alpha[_row][_col];
				var _final_alpha = _alpha == 1 ? _char_alpha : _alpha;
				
				if (_color == c_white)	var _final_color = _char_color;
				else {
					var _char_color_r = color_get_red(_char_color)/255;
					var _char_color_g = color_get_green(_char_color)/255;
					var _char_color_b = color_get_blue(_char_color)/255;
				
					var _blend_color_r = color_get_red(_color)/255;
					var _blend_color_g = color_get_green(_color)/255;
					var _blend_color_b = color_get_blue(_color)/255;
				
					var _final_color = make_color_rgb(_char_color_r * _blend_color_r * 255, _char_color_g * _blend_color_g * 255, _char_color_b * _blend_color_b * 255);
				}
				
				var _char_char = global.spritescribe_draw_cache[$ _key].chars[_row][_col];
				
				var _initial_angle = point_direction(_initial_x, _initial_y, _pos_x, _pos_y);
				var _distance = point_distance(_initial_x, _initial_y, _pos_x, _pos_y);
				var _new_angle = _initial_angle + _angle;
				var _new_x = _initial_x + lengthdir_x(_distance, _new_angle);
				var _new_y = _initial_y + lengthdir_y(_distance, _new_angle);
				
				if (_final_alpha > 0)	draw_text_transformed_color(_new_x, _new_y, _char_char, _font_scale_h, _font_scale_v, _angle, _final_color, _final_color, _final_color, _final_color, _final_alpha);
			
				_pos_x += _font_w + _font_h_spacing;
			}
			_pos_x = _x - _xoffset;
			_pos_y += _font_h + _font_v_spacing;
		}
		
	}
}

function draw_sprite_ascii(_sprite, _image, _x, _y, _font_scale_h=SPRITESCRIBE_DEFAULT_FONT_H_SCALE, _font_scale_v=SPRITESCRIBE_DEFAULT_FONT_V_SCALE, _font_h_spacing=0, _font_v_spacing=0, _force_redraw=false) {
	draw_sprite_ascii_ext(_sprite, _image, _x, _y, 1, 1, 0, c_white, 1,  _font_scale_h, _font_scale_v, _font_h_spacing, _font_v_spacing,  _force_redraw);
}

function draw_self_ascii_ext(_xscale, _yscale, _font_scale_h=SPRITESCRIBE_DEFAULT_FONT_H_SCALE, _font_scale_v=SPRITESCRIBE_DEFAULT_FONT_V_SCALE,_font_h_spacing=0, _font_v_spacing=0, _force_redraw=false) {
	draw_sprite_ascii_ext(self.sprite_index, self.image_index, self.x, self.y, _xscale, _yscale, self.image_angle, self.image_blend, self.image_alpha, _font_scale_h, _font_scale_v, _font_h_spacing, _font_v_spacing, _force_redraw);
}

function draw_self_ascii(_font_scale_h=SPRITESCRIBE_DEFAULT_FONT_H_SCALE, _font_scale_v=SPRITESCRIBE_DEFAULT_FONT_V_SCALE, _font_h_spacing=0, _font_v_spacing=0, _force_redraw=false) {
	draw_sprite_ascii_ext(self.sprite_index, self.image_index, self.x, self.y, self.image_xscale, self.image_yscale, self.image_angle, self.image_blend, self.image_alpha, _font_scale_h, _font_scale_v, _font_h_spacing, _font_v_spacing, _force_redraw);
}

function preprocess_sprites_to_ascii(_sprite_array, _xscale = 1, _yscale = 1, _angle = 0, _color=c_white, _alpha=1) {
	array_foreach(_sprite_array, method({_xscale, _yscale, _angle, _color, _alpha}, function(_sprite) {
		var _n = sprite_get_number(_sprite);
		for (var _i=0; _i<_n; _i++)		sprite_to_ascii(_sprite, _i, _xscale, _yscale, _angle, _color, _alpha);		
	}));
}

function preprocess_sprites_to_ascii_by_tags(_tag_array, _xscale = 1, _yscale = 1, _angle = 0, _color=c_white, _alpha=1) {
	var _sprite_array = [];
	for (var _i=0, _n=array_length(_tag_array); _i<_n; _i++)	_sprite_array = array_concat(_sprite_array, tag_get_asset_ids(_tag_array[_i], asset_sprite));
	preprocess_sprites_to_ascii(_sprite_array, _xscale, _yscale, _angle, _color, _alpha);
}
