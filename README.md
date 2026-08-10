![plane blueprints](aerodynamics.jpg)

# aerodynamicsWM

an "infinite canvas"-style WM for X11.

## what it does

* **pan/zoom canvas**: your windows live in unbounded space. move them wherever. zoom out and see everything. zoom in on what matters.
* **floating only**: no tiling bullshit. windows go where you put them. if you wanted constraints, use a tiler.
* **lua config**: embedded lua interpreter. configure it how you want. or don't.
* **ICCCM/EWMH**: plays nice with the x11 ecosystem. respects standards. doesn't reinvent them.
* **xft rendering**: font rendering that doesn't make your eyes bleed.

## why this exists

mostly because existing WMs either
- sucks
- are too simple
- do nothing

so we sidestep this problem completely, by making windows live in an unbounded space, this makes invisible, mental worspaces, and its just awesome.

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

iTime, iResolution passed automatically. sample textures if you want. solid color works too.

---

## running

```text
aerodynamicsWM
```

replaces your current wm. if it breaks, you have bigger problems.

## why "aerodynamicsWM"

Because it sounded cool, short-from `awm`
