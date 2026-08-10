use crate::canvas::Canvas;
use crate::config::Config;
use anyhow::Result;
use log::debug;
use xcb::{Connection, Event, Xid};

pub struct X11 {
    conn: Connection,
    screen_num: i32,
    root: xcb::x::Window,
    width: u16,
    height: u16,
}

impl X11 {
    pub fn new() -> Result<Self> {
        let (conn, screen_num) = xcb::Connection::connect(None)?;
        let screen = conn.get_setup().roots().nth(screen_num as usize).ok_or(
            anyhow::anyhow!("failed to get screen"),
        )?;

        let root = screen.root();
        let width = screen.width_in_pixels();
        let height = screen.height_in_pixels();

        conn.send_request(&xcb::x::ChangeWindowAttributes {
            window: root,
            value_list: &[
                xcb::x::Cw::EventMask(
                    xcb::x::EventMask::SUBSTRUCTURE_REDIRECT
                        | xcb::x::EventMask::SUBSTRUCTURE_NOTIFY
                        | xcb::x::EventMask::PROPERTY_CHANGE
                        | xcb::x::EventMask::FOCUS_CHANGE,
                ),
            ],
        });
        conn.flush();

        Ok(Self {
            conn,
            screen_num,
            root,
            width,
            height,
        })
    }

    pub fn run(&mut self, canvas: &mut Canvas, cfg: &Config) -> Result<()> {
        loop {
            if let Ok(Some(event)) = self.conn.poll_for_event() {
                self.handle_event(event, canvas, cfg)?;
            } else {
                canvas.update(cfg)?;
                canvas.render()?;
                std::thread::sleep(std::time::Duration::from_millis(16));
            }
        }
    }

    fn handle_event(
        &mut self,
        event: Event,
        canvas: &mut Canvas,
        cfg: &Config,
    ) -> Result<()> {
        match event {
            xcb::Event::X(xcb::x::Event::MapRequest(e)) => {
                debug!("map request for window {}", e.window().resource_id());
                canvas.add_window(e.window().resource_id(), cfg)?;
            }
            xcb::Event::X(xcb::x::Event::UnmapNotify(e)) => {
                debug!("unmap notify for window {}", e.window().resource_id());
                canvas.remove_window(e.window().resource_id())?;
            }
            xcb::Event::X(xcb::x::Event::DestroyNotify(e)) => {
                debug!("destroy notify for window {}", e.window().resource_id());
                canvas.remove_window(e.window().resource_id())?;
            }
            xcb::Event::X(xcb::x::Event::MotionNotify(e)) => {
                canvas.on_motion(e.event_x() as f32, e.event_y() as f32)?;
            }
            xcb::Event::X(xcb::x::Event::ButtonPress(e)) => {
                canvas.on_button_press(e.detail(), e.event_x() as f32, e.event_y() as f32)?;
            }
            xcb::Event::X(xcb::x::Event::ButtonRelease(e)) => {
                canvas.on_button_release(e.detail())?;
            }
            _ => {
                debug!("unhandled event: {:?}", event);
            }
        }
        Ok(())
    }
}