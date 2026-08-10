use anyhow::Result;
use mlua::Lua;
use std::path::PathBuf;

pub struct Config {
    pub gravity: f32,
    pub friction: f32,
    pub elasticity: f32,
    pub physics_enabled: bool,
    pub border_width: u8,
    pub focus_color: String,
    pub mod_key: u32,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            gravity: 0.0,
            friction: 0.9,
            elasticity: 0.5,
            physics_enabled: false,
            border_width: 2,
            focus_color: "#ff6600".to_string(),
            mod_key: 64,
        }
    }
}

pub fn load() -> Result<Config> {
    let cfg_path = dirs::config_dir()
        .map(|d| d.join("awm/config.lua"))
        .unwrap_or_else(|| PathBuf::from("~/.config/awm/config.lua"));

    if !cfg_path.exists() {
        return Ok(Config::default());
    }

    let lua = Lua::new();
    let code = std::fs::read_to_string(&cfg_path)?;
    lua.load(&code).exec()?;

    let globals = lua.globals();
    let mut cfg = Config::default();

    if let Ok(gravity) = globals.get::<_, f32>("gravity") {
        cfg.gravity = gravity;
    }
    if let Ok(friction) = globals.get::<_, f32>("friction") {
        cfg.friction = friction;
    }
    if let Ok(elasticity) = globals.get::<_, f32>("elasticity") {
        cfg.elasticity = elasticity;
    }
    if let Ok(enabled) = globals.get::<_, bool>("physics_enabled") {
        cfg.physics_enabled = enabled;
    }
    if let Ok(width) = globals.get::<_, i32>("border_width") {
        cfg.border_width = width as u8;
    }
    if let Ok(color) = globals.get::<_, String>("focus_color") {
        cfg.focus_color = color;
    }
    if let Ok(key) = globals.get::<_, i32>("mod_key") {
        cfg.mod_key = key as u32;
    }

    Ok(cfg)
}