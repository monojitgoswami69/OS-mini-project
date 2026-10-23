#!/usr/bin/env bash
# ==============================================================================
# menu.sh - OS Mini Project Interactive Launcher
# Launches Project 1 (Snake Game) or Project 2 (ASCII Running Clock)
# Compatible with macOS, Linux, WSL, and BSD
# ==============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNAKE_BIN="${SCRIPT_DIR}/snake.sh"
CLOCK_BIN="${SCRIPT_DIR}/clock.sh"

cleanup() {
    printf "\033[?25h\033[0m\033[2J\033[H"
    exit 0
}
trap cleanup INT TERM EXIT

printf "\033[?25l"

while true; do
    printf "\033[2J\033[H"

    # Terminal size detection
    size=$(stty size 2>/dev/null || echo "24 80")
    read -r t_rows t_cols <<< "$size"
    [ -z "$t_rows" ] || [ "$t_rows" -le 0 ] && t_rows=24
    [ -z "$t_cols" ] || [ "$t_cols" -le 0 ] && t_cols=80

    box_w=62
    start_c=$(( (t_cols - box_w) / 2 ))
    [ "$start_c" -lt 1 ] && start_c=1
    start_r=$(( (t_rows - 18) / 2 ))
    [ "$start_r" -lt 1 ] && start_r=1

    r=$start_r
    # Header Banner
    printf "\033[%d;%dH\033[1;38;5;46m╭────────────────────────────────────────────────────────────╮\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[1;38;5;226m            ⚡ OPERATING SYSTEMS MINI PROJECT SUITE ⚡        \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[38;5;157m               Shell Script Programming & Terminal UI        \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m├────────────────────────────────────────────────────────────┤\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│                                                            │\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[1;38;5;255m   [1] 🐍 PROJECT 1: MODERN TERMINAL SNAKE GAME               \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[38;5;244m       • Interactive real-time shell-based game              \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[38;5;244m       • Delta rendering, score HUD, wrap-around portals     \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│                                                            │\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[1;38;5;255m   [2] ⏰ PROJECT 2: ASCII RUNNING DIGITAL CLOCK              \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[38;5;244m       • Centered terminal display via Unix 'date'           \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[38;5;244m       • Multi-font styles, blinking colons, live themes     \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│                                                            │\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│\033[1;38;5;255m   [Q] 🚪 EXIT                                                \033[1;38;5;46m│\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m│                                                            │\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[1;38;5;46m╰────────────────────────────────────────────────────────────╯\033[0m" "$r" "$start_c"; r=$((r+1))
    printf "\033[%d;%dH\033[38;5;242m  Select an option [1, 2] or [Q] to quit:                     \033[0m" "$r" "$start_c"

    # Wait for key
    orig_s=$(stty -g 2>/dev/null || true)
    stty -echo -icanon min 0 time 0 2>/dev/null || true
    choice=""
    while [ -z "$choice" ]; do
        choice=$(dd bs=10 count=1 2>/dev/null || true)
        sleep 0.05
    done
    stty "$orig_s" 2>/dev/null || true

    case "$choice" in
        1)
            "$SNAKE_BIN"
            ;;
        2)
            "$CLOCK_BIN"
            ;;
        q|Q|$'\e')
            cleanup
            ;;
    esac
done
