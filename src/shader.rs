use anyhow::Result;

pub struct Shader {
    source: String,
    compiled: bool,
}

impl Shader {
    pub fn new(source: &str) -> Result<Self> {
        Ok(Self {
            source: source.to_string(),
            compiled: false,
        })
    }

    pub fn compile(&mut self) -> Result<()> {
        Ok(())
    }

    pub fn render(&self, width: u32, height: u32, time: f32) -> Result<Vec<u8>> {
        Ok(vec![])
    }
}
