extern crate ggez;
use ggez::conf;
use ggez::event;
use ggez::{Context, GameResult};
use ggez::graphics;
use std::time::Duration;


// First we make a structure to contain the game's state
struct InterpolatedGameLoop {
    text: graphics::Text,
    frames: usize,
    initialized: bool,
    rob_game_state: GameState,
}

struct GameState {
    dt_accum: Duration,
    fixed_frame_dt: Duration,
}

impl GameState {
    fn idle_update(&self, dt: Duration) {
        print!("{:?}\n", dt);
    }

    fn fixed_update(&self, dt: Duration) {

    }
}

// Then we implement the `ggez:event::EventHandler` trait on it, which
// requires callbacks for updating and drawing the game state each frame.
//
// The `EventHandler` trait also contains callbacks for event handling
// that you can override if you wish, but the defaults are fine.
impl InterpolatedGameLoop {
    fn new(ctx: &mut Context) -> GameResult<InterpolatedGameLoop> {
        let font = graphics::Font::new(ctx, "/DejaVuSerif.ttf", 48)?;
        let text = graphics::Text::new(ctx, "Hello world!", &font)?;

        let s = InterpolatedGameLoop {
            text: text,
            frames: 0,
            initialized: false,
            rob_game_state: GameState {
                dt_accum: Duration::new(0u64, 0u32),
                fixed_frame_dt: Duration::new(1u64, 0u32) / 60,
            },
        };
        return Ok(s);
    }
}

impl event::EventHandler for InterpolatedGameLoop {
    fn update(&mut self, _ctx: &mut Context, dt: Duration) -> GameResult<()> {
        // Skip the first frame, because the first frame always has an extremely long dt
        if (!self.initialized) {
            self.initialized = true;
            return Ok(());
        }
        let rgs: &mut GameState = &mut(self.rob_game_state);
        rgs.idle_update(dt);

        rgs.dt_accum = rgs.dt_accum + dt;
        while rgs.dt_accum > rgs.fixed_frame_dt {
            rgs.dt_accum = rgs.dt_accum - rgs.fixed_frame_dt;
            rgs.fixed_update(rgs.fixed_frame_dt);
        }
        return Ok(());
    }

    fn draw(&mut self, ctx: &mut Context) -> GameResult<()> {
        graphics::clear(ctx);
        // Drawables are drawn from their center.
        let dest_point = graphics::Point::new(self.text.width() as f32 / 2.0 + 10.0,
                                              self.text.height() as f32 / 2.0 + 10.0);
        graphics::draw(ctx, &self.text, dest_point, 0.0)?;
        graphics::present(ctx);
        self.frames += 1;
        if (self.frames % 100) == 0 {
            println!("FPS: {}", ggez::timer::get_fps(ctx));
        }
        return Ok(());
    }
}

// Now our main function, which does three things:
//
// * First, create a new `ggez::conf::Conf`
// object which contains configuration info on things such
// as screen resolution and window title,
// * Second, create a `ggez::game::Game` object which will
// do the work of creating our InterpolatedGameLoop and running our game,
// * then just call `game.run()` which runs the `Game` mainloop.
pub fn main() {
    let c = conf::Conf::new();
    let ctx = &mut Context::load_from_conf("helloworld", "ggez", c).unwrap();
    let game_loop = &mut InterpolatedGameLoop::new(ctx).unwrap();
    if let Err(e) = event::run(ctx, game_loop) {
        println!("Error encountered: {}", e);
    } else {
        println!("Game exited cleanly.");
    }
}
