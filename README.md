![plane blueprints](aerodynamics.jpg)

# aerodynamicsWM

an infinite canvas x11 window manager. you wanted floating windows that don't suck. here it is.

## what it does

* **pan/zoom canvas**: your windows live in unbounded space. move them wherever. zoom out and see everything. zoom in on what matters.
* **floating only**: no tiling bullshit. windows go where you put them. if you wanted constraints, use a tiler.
* **lua config**: embedded lua interpreter. configure it how you want. or don't.
* **ICCCM/EWMH**: plays nice with the x11 ecosystem. respects standards. doesn't reinvent them.
* **xft rendering**: font rendering that doesn't make your eyes bleed.

## why this exists

existing wms either:

* tile everything and pretend stacking windows don't exist
* stack windows and pretend you don't need workspaces
* add "features" until they're 50k lines of unmaintainable crud

this doesn't solve that problem. it just sidesteps it. infinite canvas means you're not choosing between tiling and stacking. you're choosing between *here* and *there*.

## building

requires:

* x11 dev headers
* rust 1.70+

```text
cargo build --release
```

binary goes to `target/release/aerodynamicsWM`.

## configuring

config lives in `~/.config/awm/config.lua`. embedded lua runs it at startup.

example:

```text
(define mod-key 64)  ; super
(define border-width 2)
(define focus-color "#ff6600")

(keybind mod-key (key "q") (lambda () (exit)))
```

no defaults. write what you need. delete what you don't.

### physics

windows can have momentum. gravity. friction. collision. or none of it. your choice.

```text
gravity = 0.1
friction = 0.92
elasticity = 0.6
physics_enabled = true
```

windows dragged and released will slide across the canvas. they stop when friction wins. bounce off edges if elasticity > 0. or turn it all off and windows stay put.

### wallpaper shaders

background is a shader. write glsl. runs every frame.

```text
wallpaper_shader = [[
  uniform float time;
  uniform vec2 resolution;
  
  void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    vec3 col = vec3(sin(uv.x * 10.0 + time) * 0.5 + 0.5);
    gl_FragColor = vec4(col, 1.0);
  }
]]
```

iTime, iResolution passed automatically. sample textures if you want. or don't. solid color works too.

---

## running

```text
aerodynamicsWM
```

replaces your current wm. if it breaks, you have bigger problems.

## license

GPLv3. copy it, modify it, run it on a toaster. don't sell it to people.

## why "aerodynamicsWM"

short: `awm`. clean. sounds like something that actually moves.

long: stacking windows in unbounded space is just fluid dynamics with rectangles. might as well name it accordingly.

---

do one thing. do it well. your windows float now. stop complaining.

