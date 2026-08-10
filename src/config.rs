use anyhow::Result;
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
        .map(|d| d.join("awm/config.scm"))
        .unwrap_or_else(|| PathBuf::from("~/.config/awm/config.scm"));

    if !cfg_path.exists() {
        return Ok(Config::default());
    }

    let mut cfg = Config::default();

    Ok(cfg)
}
