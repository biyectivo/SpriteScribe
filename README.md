# SpriteScribe

DISCLAIMER: This is more of an experiment than a library. It is experimental, incomplete, non-optimized and just plain dumb. Also it will probably not be updated. Use only for fun :D

SpriteScribe is a tiny set of functions to render a sprite with colored, rotated and scaled ASCII characters from your font of choice.

## Requirements & How to install

This script should work with most modern versions of Gamemaker LTS or above.

You should download and import the YYMPS (or manually import both scripts) into your project.

## How to use

You need to process a sprite before rendering it. You can either do this on demand at runtime (if small) or preprocess it at game start (if big/multiple).

## How to view a demo

You can head [here](https://manta-ray.itch.io/spritescribe) to view a demo. I recommend you check out the Windows version of the demo, since the WASM-based HTML version performs worse.

## How it works

SpriteScribe works by first processing a sprite to extract the color data per pixel and then create a matrix of appropriate characters for each position (the appropriate character is chosen based on pixel luminance). This is then stored into a cache. After this is done, SpriteScribe renders the sprite by drawing the text characters per each pixel using the selected font and some additional data.

### Step 1: Processing the sprite

#### Processing on demand

Use the `sprite_to_ascii` function. The parameters are self-explanatory:

`sprite_to_ascii(_sprite, _image, _xscale, _yscale, _angle, _color, _alpha)`

Here: 

* `_sprite` - The sprite resource to process
* `_image` - The frame number to process
* `_xscale` and `_yscale` - The scale you need the processing to be done, useful more for scaling down big sprites to ease processing
* `_angle` - The angle to process
* `_color` - The blend color to use while processing
* `_alpha` - The alpha to use while processing

#### Pre-processing sprites

You can pre-process sprites at game start (or whenever deemed appropriate). You can either pass an array of sprites to `preprocess_sprites_to_ascii`, or provide an array of tags instead and use `preprocess_sprites_to_ascii_by_tags`. Both of these functions will process all frames of each sprite and store the result into the global cache.

### Step 2: Rendering the ASCII art

Once a sprite is processed, you can use the different `draw_sprite_ascii_*` or `draw_self_ascii_*` functions to render. All of the functions use a single one that actually performs the rendering, `draw_sprite_ascii_ext`. The syntax is as follows:

`draw_sprite_ascii_ext(_sprite, _image, _x, _y, _font_scale_h, _font_scale_v, _angle, _color, _alpha, _font_h_spacing=0, _font_v_spacing=0)`

Here:

* `_sprite` - The sprite for which to render as ASCII
* `_image` - The frame number to render as ASCII
  Note that the key of the global cache is defined by the combination of the sprite name and the frame number.
* `_x` and `_y` - The position where to draw (respecting the original sprite's anchor point defined by `xoffset` and `yoffset`
* `_font_scale_h` and `_font_scale_v` - The font scale to use when drawing. By default, the font scale used is such that one character is equivalent to one pixel and hence the size of the drawn ASCII sprite will be the same as the original sprite - but this will almost never be what you want, since you cannot have a font of 1px for obvious reasons. So you can increase this number to better see the font, increasing the ASCII sprite size accordingly.
* `_angle` - The angle to render the ASCII art
* `_color` - The blend color to use when rendering the ASCII art
* `_alpha` - The alpha to use for rendering the ASCII art
* `_font_h_spacing` and `_font_v_spacing` - The space between characters. By default, this is 0, but you can select a negative number (to overlap characters) or positive number (to space out characters)

## Performance

Not very good, and not rigorously measured, but you can make your own experiments... For a fun experiment or jam game I think it's ok.

## Credits

The library uses YellowAfterlife's `buffer_getpixel_*` functions available [here](https://github.com/YAL-GameMaker/buffer_getpixel) to drastically speed up getting the color/alpha of each pixel in the sprite when processing it.

The fantastic animated dragon sprite can be found [here](https://free-game-assets.itch.io/dragon-pixel-art-character-sprite-sheets-pack)