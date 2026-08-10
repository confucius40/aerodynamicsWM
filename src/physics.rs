use crate::config::Config;
use crate::window::Window;
use anyhow::Result;

pub struct Physics {
    gravity: f32,
    friction: f32,
    elasticity: f32,
    enabled: bool,
}

impl Physics {
    pub fn from_config(cfg: &Config) -> Result<Self> {
        Ok(Self {
            gravity: cfg.gravity,
            friction: cfg.friction,
            elasticity: cfg.elasticity,
            enabled: cfg.physics_enabled,
        })
    }

    pub fn enabled(&self) -> bool {
        self.enabled
    }

    pub fn apply(&self, win: &mut Window) {
        if !self.enabled {
            return;
        }

        let (mut vx, mut vy) = win.velocity();

        vy += self.gravity;
        vx *= self.friction;
        vy *= self.friction;

        let (mut x, mut y) = win.position();
        x += vx;
        y += vy;

        const CANVAS_WIDTH: f32 = 10000.0;
        const CANVAS_HEIGHT: f32 = 10000.0;

        if x < 0.0 {
            x = 0.0;
            vx = -vx * self.elasticity;
        }
        if x + 800.0 > CANVAS_WIDTH {
            x = CANVAS_WIDTH - 800.0;
            vx = -vx * self.elasticity;
        }

        if y < 0.0 {
            y = 0.0;
            vy = -vy * self.elasticity;
        }
        if y + 600.0 > CANVAS_HEIGHT {
            y = CANVAS_HEIGHT - 600.0;
            vy = -vy * self.elasticity;
        }

        win.set_position(x, y);
        win.set_velocity(vx, vy);
    }
}