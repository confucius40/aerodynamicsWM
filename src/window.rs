use crate::config::Config;
use anyhow::Result;

pub struct Window {
    id: u32,
    x: f32,
    y: f32,
    width: u16,
    height: u16,
    vx: f32,
    vy: f32,
}

impl Window {
    pub fn new(id: u32, x: f32, y: f32, cfg: &Config) -> Result<Self> {
        Ok(Self {
            id,
            x,
            y,
            width: 800,
            height: 600,
            vx: 0.0,
            vy: 0.0,
        })
    }

    pub fn id(&self) -> u32 {
        self.id
    }

    pub fn contains(&self, px: f32, py: f32) -> bool {
        px >= self.x && px < self.x + self.width as f32 && py >= self.y
            && py < self.y + self.height as f32
    }

    pub fn move_by(&mut self, dx: f32, dy: f32) {
        self.x += dx;
        self.y += dy;
    }

    pub fn set_velocity(&mut self, vx: f32, vy: f32) {
        self.vx = vx;
        self.vy = vy;
    }

    pub fn velocity(&self) -> (f32, f32) {
        (self.vx, self.vy)
    }

    pub fn position(&self) -> (f32, f32) {
        (self.x, self.y)
    }

    pub fn set_position(&mut self, x: f32, y: f32) {
        self.x = x;
        self.y = y;
    }
}
