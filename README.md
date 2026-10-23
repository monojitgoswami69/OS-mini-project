# 🎮 OS Mini Project: Terminal Arcade Suite

A modern, highly polished, zero-dependency terminal suite implementing **Project 1: Terminal Snake Game** and **Project 2: ASCII Running Digital Clock** in pure POSIX/Bash.

Built with strict cross-platform compatibility for **macOS (default Bash 3.2+)**, **Linux (GNU Bash 4/5)**, **WSL (Windows Subsystem for Linux)**, and **BSD**.

---

## 🌟 Overview & Problem Statements

### Project 1: Modern Terminal Snake Game (`snake.sh`)
> **Problem Statement:** Design and implement a Snake Game using a Shell Script. The game should provide an interactive terminal-based user interface where the snake can move in different directions, grow in length upon eating food, and end the game when the snake collides with itself or the boundary. The script should handle user input, game logic, and screen updates within the shell environment.

#### ✨ Modern Enhancements:
- **Zero-Flicker Delta Rendering Engine**: Only changed cells (head advance, former head to body, tail erase) are redrawn each frame, achieving ultra-smooth 60 FPS performance without screen tearing.
- **Aspect-Ratio Correction**: Uses 16:10 arena geometry with double-width cells (`2 cols : 1 row`) so grid cells form perfect geometric squares rather than squished rectangles.
- **Responsive Controls**: Full support for **Arrow Keys**, **WASD**, and **Vim Keys (HJKL)** with instant direction response.
- **Score Overlay & In-Game HUD**: Clean borderless top display showing live score and session high score.
- **Dynamic Difficulty**: 4 difficulty presets (*Casual*, *Normal*, *Hard*, *Insane*) with subtle in-game speed acceleration as your score climbs.
- **Persistent High Score**: Saves record score persistently to `~/.snake_highscore`.
- **Full-Screen Crimson Game Over Overlay**: Centered translucent statistical breakdown with instant restart (`R`), menu (`M`), and exit (`Q`).
- **Pause System**: Frosted `[PAUSED]` card with an automatic `3... 2... 1... GO!` unpause countdown.
- **5 Curated Color Themes**: Emerald Arcade (classic matrix green), Cyberpunk Neon (cyan/magenta), Synthwave Sunset (hot pink/gold), Ice Blue, and Monochrome CRT.
- **Portal Mode Default**: Smooth wrap-around portal boundaries by default, with optional classic solid boundary collision.

---

### Project 2: ASCII Running Digital Clock (`clock.sh`)
> **Problem Statement:** A running clock: Write an executable bash script `clock.sh` that keeps on printing the current time at the center of the terminal in an ASCII format (not as a string), and updates the display at regular intervals (like every second or every half a second). The current time (and date) can be obtained by the Unix command `date`.

#### ✨ Modern Enhancements:
- **Default Visual Style**: Modern Bold Block font (`█████`) in vibrant **Cyberpunk Neon** (Cyan & Magenta) with a clean, borderless floating widget layout.
- **Centered Real-Time Display**: Dynamically auto-centers the clock vertically and horizontally, updating automatically when the terminal is resized (`WINCH` signal).
- **High-Visibility Date & Day**: Clean 2-line header showing capitalized, letter-spaced Day (`S A T U R D A Y`) and Date (`10 October 2026`).
- **Clean 24H Mode**: Pure digital readout without unnecessary trailing labels, with calibrated character spacing so borders never break.
- **Blinking Colon Separators**: Flashes colon separators every half-second interval (matching the visual reference from the assignment).
- **Unix `date` Integration**: Uses the Unix `date` utility to obtain local time, date, and AM/PM state.
- **Minimalist Muted Controls**: Single-line muted grey controls bar at the bottom. Press `H` to toggle controls, and press `H`, `ESC`, `Space`, or `Enter` anytime to return to the clean homescreen.
- **Configurable Borders**: Borderless by default, with instant hotkey toggling (`B`) between Double (`╔═══╗`), Rounded (`╭───╮`), Dashed (`+---+`), and Solid (`┌───┐`).

---

## 🚀 Quick Start

### 1. Interactive Launcher (Recommended)
Launch the unified suite menu to pick either project:
```bash
./menu.sh
```
or via `make`:
```bash
make
```

### 2. Launch Snake Game Directly
```bash
./snake.sh
```
or:
```bash
make snake
```

### 3. Launch ASCII Running Clock Directly
```bash
./clock.sh
```
or:
```bash
make clock
```

---

## 🕹️ Controls & Keyboard Shortcuts

### Project 1: Snake Game (`snake.sh`)
| Key | Action |
|---|---|
| `↑` `↓` `←` `→` | Move Snake (Arrow Keys) |
| `W` `A` `S` `D` | Move Snake (WASD Keys) |
| `K` `H` `J` `L` | Move Snake (Vim Keys) |
| `Space` | Pause / Resume Game (with countdown) |
| `R` | Quick Restart (on Game Over screen) |
| `M` | Return to Main Menu (on Game Over screen) |
| `Q` or `ESC` | Quit / Exit |

#### CLI Flags:
```bash
./snake.sh --help
./snake.sh --difficulty 2     # 0=Casual, 1=Normal, 2=Hard, 3=Insane
./snake.sh --theme 1          # 0=Emerald, 1=Cyberpunk, 2=Synthwave, 3=Ice Blue, 4=Mono
./snake.sh --wrap             # Enable portal wrap-around boundaries
```

---

### Project 2: ASCII Running Clock (`clock.sh`)
| Key | Action |
|---|---|
| `H` or `?` | Toggle Controls card (Press `H`, `ESC`, `Space`, or `Enter` to return to homescreen) |
| `T` | Toggle 12-Hour (with AM/PM) / 24-Hour mode (pure digits without 24H text) |
| `S` | Toggle Seconds display (`HH:MM:SS` vs `HH:MM`) |
| `D` | Toggle Date header (Large 2-Line / Compact / Off) |
| `C` | Cycle Color Themes (Cyberpunk Neon, Emerald, Amber, Solar, Violet, Mono) |
| `F` | Cycle Font Styles (Modern Bold Block, Classic 7-Segment, Tech Slender) |
| `B` | Cycle Border Styles (None / Double `╔═══╗` / Rounded `╭───╮` / Dashed `+---+` / Solid `┌───┐`) |
| `Q` | Clean Exit |

#### CLI Flags:
```bash
./clock.sh --help
./clock.sh --24               # Launch directly in 24-hour mode (clean, no trailing tag)
./clock.sh --border 1         # Launch with Cyberpunk Double border
./clock.sh --theme 0          # Launch in Emerald Matrix theme
./clock.sh --font 0           # Launch in Classic 7-Segment font
./clock.sh --no-seconds       # Omit seconds
./clock.sh --no-blink         # Static colons (no flashing)
```

---

## 🛠️ Cross-Platform Compatibility Architecture

To guarantee that both scripts run out of the box on **every** Unix-like platform without runtime errors or missing package dependencies:

1. **Bash 3.2 Compatibility (macOS Default)**:
   - macOS ships by default with `/bin/bash` 3.2.57 (2007).
   - Newer features like associative arrays (`declare -A`) and fractional `read -t 0.1` are **not** present in Bash 3.2.
   - **Solution**: We designed the game engine using 1D flattened index arrays (`array[y * width + x]`) and raw character parsing (`stty -icanon -echo min 0 time 0` with `dd bs=10 count=1 2>/dev/null`), ensuring 100% compatibility across Bash 3.2, Bash 4.x, and Bash 5.x.

2. **Zero Dependencies**:
   - Requires only standard POSIX core utilities available on any macOS or Linux system: `bash`, `stty`, `dd`, `date`, `printf`, `awk`. No Python, Node, or NCurses packages needed.

3. **Terminal Signal & State Protection**:
   - Comprehensive `trap cleanup INT TERM EXIT` handlers ensure that:
     - Terminal cursor visibility is restored (`\033[?25h`).
     - Terminal echo and canonical input are restored (`stty "$ORIG_STTY"`).
     - Color styles are reset (`\033[0m`).
     - Alternate screen buffers are cleaned up cleanly.

---

## 📁 Repository Structure

```
OS-mini-project/
├── snake.sh           # Project 1: Modern Terminal Snake Game (executable)
├── clock.sh           # Project 2: ASCII Running Digital Clock (executable)
├── menu.sh            # Unified Project Launcher Menu (executable)
├── Makefile           # Quick build and run targets
└── README.md          # Comprehensive documentation & user guide
```

---

## 📝 License
Created as part of the Operating Systems Mini-Project Coursework (BL-K6 Design). Free to use, study, and modify.
