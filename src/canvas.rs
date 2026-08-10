use crate::config::Config;
use crate::physics::Physics;
use crate::window::Window;
use anyhow::Result;
use log::debug;
use std::collections::HashMap;
use xcb::x;

pub struct Canvas {
    windows: HashMap<u32, Window>,
    pan_x: f32,
    pan_y: f32,
    zoom: f32,
    physics: Physics,
    dragging: Option<u32>,
    drag_start_x: f32,
    drag_start_y: f32,
}

impl Canvas {
    pub fn new(cfg: &Config) -> Result<Self> {
        Ok(Self {
            windows: HashMap::new(),
            pan_x: 0.0,
            pan_y: 0.0,
            zoom: 1.0,
            physics: Physics::from_config(cfg)?,
            dragging: None,
            drag_start_x: 0.0,
            drag_start_y: 0.0,
        })
    }

    pub fn add_window(&mut self, window: u32, cfg: &Config) -> Result<()> {
        debug!("adding window {}", window);
        self.windows.insert(
            window,
            Window::new(window, self.pan_x, self.pan_y, cfg)?,
        );
        Ok(())
    }

    pub fn remove_window(&mut self, window: u32) -> Result<()> {
        debug!("removing window {}", window);
        self.windows.remove(&window);
        Ok(())
    }

    pub fn on_motion(&mut self, x: f32, y: f32) -> Result<()> {
        if let Some(win_id) = self.dragging {
            if let Some(win) = self.windows.get_mut(&win_id) {
                let dx = x - self.drag_start_x;
                let dy = y - self.drag_start_y;
                win.move_by(dx, dy);
                self.drag_start_x = x;
                self.drag_start_y = y;
            }
        }
        Ok(())
    }

    pub fn on_button_press(&mut self, button: u8, x: f32, y: f32) -> Result<()> {
        match button {
            1 => {
                for (_id, win) in self.windows.iter().rev() {
                    if win.contains(x, y) {
                        self.dragging = Some(win.id());
                        self.drag_start_x = x;
                        self.drag_start_y = y;
                        break;
                    }
                }
            }
            _ => {}
        }
        Ok(())
    }

    pub fn on_button_release(&mut self, button: u8) -> Result<()> {
        if button == 1 {
            self.dragging = None;
        }
        Ok(())
    }

    pub fn update(&mut self, cfg: &Config) -> Result<()> {
        if self.physics.enabled() {
            for (_id, win) in self.windows.iter_mut() {
                self.physics.apply(win);
            }
        }
        Ok(())
    }

    pub fn render(&self) -> Result<()> {
        Ok(())
    }

    pub fn pan(&mut self, dx: f32, dy: f32) {
        self.pan_x += dx;
        self.pan_y += dy;
    }

    pub fn zoom(&mut self, factor: f32) {
        self.zoom *= factor;
        if self.zoom < 0.1 {
            self.zoom = 0.1;
        }
        if self.zoom > 10.0 {
            self.zoom = 10.0;
        }
    }
}
