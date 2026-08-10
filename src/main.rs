mod x11;
mod canvas;
mod config;
mod physics;
mod shader;
mod window;

use anyhow::Result;
use log::info;
use std::env;

fn main() -> Result<()> {
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info")).init();

    info!("aerodynamicsWM starting");

    let cfg = config::load()?;
    info!("config loaded");

    let mut x = x11::X11::new()?;
    info!("x11 connection established");

    let mut c = canvas::Canvas::new(&cfg)?;
    info!("canvas initialized");

    x.run(&mut c, &cfg)?;

    Ok(())
}
