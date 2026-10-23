#!/usr/bin/env bash
# ==============================================================================
# clock.sh - Modern ASCII Running Terminal Clock
# Compatible with macOS (Bash 3.2+), Linux (Bash 4/5), BSD, and WSL
# Problem Statement: Displays real-time clock centered in terminal in ASCII format
# using the Unix 'date' command, updating at regular intervals with blinking colons.
# ==============================================================================

# Ensure UTF-8 locale for character handling across platforms
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LANG="${LANG:-en_US.UTF-8}"

# Single-byte ASCII Escape code for ANSI terminal formatting (compatible with all shells and printf %s)
ESC=$(printf '\033')

# Ensure clean exit and terminal restoration
cleanup() {
    printf "%s[?25h" "$ESC"          # Show cursor
    printf "%s[0m" "$ESC"            # Reset colors
    printf "%s[2J%s[H" "$ESC" "$ESC" # Clear screen and move home
    if [ -n "$ORIG_STTY" ]; then
        stty "$ORIG_STTY" 2>/dev/null || true
    fi
    exit 0
}

trap cleanup INT TERM EXIT

# Save original terminal settings and configure non-blocking input
ORIG_STTY=$(stty -g 2>/dev/null || true)
stty -echo -icanon min 0 time 0 2>/dev/null || true

# Hide cursor
printf "%s[?25l" "$ESC"

# Options and state
FORMAT_12H=1          # 1 = 12-hour with AM/PM, 0 = 24-hour (no 24H text)
SHOW_SECONDS=1        # 1 = Show HH:MM:SS, 0 = Show HH:MM
SHOW_DATE=1           # 1 = Large 2-Line Day & Date, 2 = Compact, 0 = Hidden
BLINK_COLON=1         # 1 = Blink colons every interval
FONT_STYLE=1          # 1 = Modern Bold Block (Default), 0 = Classic 7-Segment, 2 = Tech Slender
COLOR_THEME=1         # 1 = Cyberpunk Neon (Default), 0 = Emerald, 2 = Amber, 3 = Solar, 4 = Violet, 5 = Mono
BORDER_STYLE=0        # 0 = No border (Clean Modern Default), 1 = Double (╔═══╗), 2 = Rounded (╭───╮), 3 = Dashed (+---+), 4 = Solid (┌───┐)
SHOW_HELP=0           # 0 = Hidden, 1 = Show hotkey bar at bottom

# Parse command line options
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            echo "Usage: ./clock.sh [OPTIONS]"
            echo ""
            echo "Modern ASCII Running Digital Clock in Bash"
            echo ""
            echo "Options:"
            echo "  -12, --12h            Use 12-hour format with AM/PM (default)"
            echo "  -24, --24h            Use 24-hour format (clean without 24H label)"
            echo "  -s, --no-seconds      Hide seconds"
            echo "  -d, --no-date         Hide date header"
            echo "  -b, --border <0-4>    Border style (0=None, 1=Double, 2=Rounded, 3=Dashed, 4=Solid)"
            echo "  --no-blink            Disable blinking colons"
            echo "  -c, --theme <0-5>     Color theme (1=Cyberpunk, 0=Emerald, 2=Amber, 3=Solar, 4=Violet, 5=Mono)"
            echo "  -f, --font <0-2>      Font style (1=Modern Bold Block, 0=Classic 7-Segment, 2=Tech Slender)"
            echo "  -h, --help            Show this help message and exit"
            echo ""
            echo "Keyboard Controls while running:"
            echo "  q, ESC   : Quit clock"
            echo "  h, ?     : Toggle controls / Return to homescreen"
            echo "  t        : Toggle 12h / 24h mode"
            echo "  s        : Toggle seconds display"
            echo "  d        : Toggle date display (Large / Compact / Off)"
            echo "  c        : Cycle color themes"
            echo "  f        : Cycle font styles"
            echo "  b        : Cycle border styles (None / Double / Rounded / Dashed / Solid)"
            exit 0
            ;;
        -12|--12h) FORMAT_12H=1 ;;
        -24|--24h) FORMAT_12H=0 ;;
        -s|--no-seconds) SHOW_SECONDS=0 ;;
        -d|--no-date) SHOW_DATE=0 ;;
        -b|--border)
            shift
            if [ -n "${1:-}" ]; then BORDER_STYLE="$1"; fi
            ;;
        --no-blink) BLINK_COLON=0 ;;
        -c|--theme)
            shift
            if [ -n "${1:-}" ]; then COLOR_THEME="$1"; fi
            ;;
        -f|--font)
            shift
            if [ -n "${1:-}" ]; then FONT_STYLE="$1"; fi
            ;;
    esac
    shift
done

update_term_size() {
    local size
    size=$(stty size 2>/dev/null || echo "24 80")
    read -r TERM_ROWS TERM_COLS <<< "$size"
    [ -z "$TERM_ROWS" ] || [ "$TERM_ROWS" -le 0 ] && TERM_ROWS=24
    [ -z "$TERM_COLS" ] || [ "$TERM_COLS" -le 0 ] && TERM_COLS=80
    printf "%s[2J" "$ESC"  # Clear screen on resize
}

trap update_term_size WINCH

# ------------------------------------------------------------------------------
# Color Palettes
# ------------------------------------------------------------------------------
get_theme_colors() {
    case "$COLOR_THEME" in
        0) # Emerald Matrix Green
            COLOR_BORDER="${ESC}[38;5;46m"
            COLOR_DIGIT="${ESC}[1;38;5;48m"
            COLOR_COLON="${ESC}[1;38;5;120m"
            COLOR_DATE="${ESC}[1;38;5;46m"
            COLOR_DATE_SUB="${ESC}[1;38;5;157m"
            COLOR_AMPM="${ESC}[1;38;5;119m"
            THEME_NAME="Emerald Matrix"
            ;;
        1) # Cyberpunk Neon
            COLOR_BORDER="${ESC}[38;5;51m"
            COLOR_DIGIT="${ESC}[1;38;5;51m"
            COLOR_COLON="${ESC}[1;38;5;201m"
            COLOR_DATE="${ESC}[1;38;5;201m"
            COLOR_DATE_SUB="${ESC}[1;38;5;51m"
            COLOR_AMPM="${ESC}[1;38;5;201m"
            THEME_NAME="Cyberpunk Neon"
            ;;
        2) # Amber CRT Terminal
            COLOR_BORDER="${ESC}[38;5;214m"
            COLOR_DIGIT="${ESC}[1;38;5;220m"
            COLOR_COLON="${ESC}[1;38;5;208m"
            COLOR_DATE="${ESC}[1;38;5;214m"
            COLOR_DATE_SUB="${ESC}[1;38;5;222m"
            COLOR_AMPM="${ESC}[1;38;5;214m"
            THEME_NAME="Amber CRT"
            ;;
        3) # Solarized Gold
            COLOR_BORDER="${ESC}[38;5;178m"
            COLOR_DIGIT="${ESC}[1;38;5;221m"
            COLOR_COLON="${ESC}[1;38;5;166m"
            COLOR_DATE="${ESC}[1;38;5;220m"
            COLOR_DATE_SUB="${ESC}[1;38;5;229m"
            COLOR_AMPM="${ESC}[1;38;5;178m"
            THEME_NAME="Solar Gold"
            ;;
        4) # Electric Violet
            COLOR_BORDER="${ESC}[38;5;141m"
            COLOR_DIGIT="${ESC}[1;38;5;183m"
            COLOR_COLON="${ESC}[1;38;5;199m"
            COLOR_DATE="${ESC}[1;38;5;199m"
            COLOR_DATE_SUB="${ESC}[1;38;5;141m"
            COLOR_AMPM="${ESC}[1;38;5;141m"
            THEME_NAME="Electric Violet"
            ;;
        5) # Sleek Monochrome
            COLOR_BORDER="${ESC}[38;5;248m"
            COLOR_DIGIT="${ESC}[1;38;5;255m"
            COLOR_COLON="${ESC}[1;38;5;250m"
            COLOR_DATE="${ESC}[1;38;5;255m"
            COLOR_DATE_SUB="${ESC}[1;38;5;248m"
            COLOR_AMPM="${ESC}[1;38;5;245m"
            THEME_NAME="Pure Monochrome"
            ;;
    esac
    COLOR_RESET="${ESC}[0m"
    COLOR_DIM="${ESC}[38;5;240m"
}

# ------------------------------------------------------------------------------
# ASCII Glyphs Definition
# ------------------------------------------------------------------------------

# Style 0: Classic 3-Line 7-Segment (True to Assignment Reference)
# Digits are 3 chars wide, 3 lines tall
get_classic_glyph() {
    local char="$1"
    local line="$2"
    local show_colon="$3"
    case "$char" in
        0) [ "$line" -eq 1 ] && echo " _ " || { [ "$line" -eq 2 ] && echo "| |" || echo "|_|"; } ;;
        1) [ "$line" -eq 1 ] && echo "   " || { [ "$line" -eq 2 ] && echo "  |" || echo "  |"; } ;;
        2) [ "$line" -eq 1 ] && echo " _ " || { [ "$line" -eq 2 ] && echo " _|" || echo "|_ "; } ;;
        3) [ "$line" -eq 1 ] && echo " _ " || { [ "$line" -eq 2 ] && echo " _|" || echo " _|"; } ;;
        4) [ "$line" -eq 1 ] && echo "   " || { [ "$line" -eq 2 ] && echo "|_|" || echo "  |"; } ;;
        5) [ "$line" -eq 1 ] && echo " _ " || { [ "$line" -eq 2 ] && echo "|_ " || echo " _|"; } ;;
        6) [ "$line" -eq 1 ] && echo " _ " || { [ "$line" -eq 2 ] && echo "|_ " || echo "|_|"; } ;;
        7) [ "$line" -eq 1 ] && echo " _ " || { [ "$line" -eq 2 ] && echo "  |" || echo "  |"; } ;;
        8) [ "$line" -eq 1 ] && echo " _ " || { [ "$line" -eq 2 ] && echo "|_|" || echo "|_|"; } ;;
        9) [ "$line" -eq 1 ] && echo " _ " || { [ "$line" -eq 2 ] && echo "|_|" || echo " _|"; } ;;
        :)
            if [ "$show_colon" -eq 1 ]; then
                [ "$line" -eq 1 ] && echo " " || { [ "$line" -eq 2 ] && echo ":" || echo "."; }
            else
                echo " "
            fi
            ;;
        " ") echo " " ;;
        *) echo "   " ;;
    esac
}

# Style 1: Modern Bold Block (5 lines tall)
get_block_glyph() {
    local char="$1"
    local line="$2"
    local show_colon="$3"
    case "$char" in
        0)
            case "$line" in
                1) echo "█████" ;;
                2) echo "█   █" ;;
                3) echo "█   █" ;;
                4) echo "█   █" ;;
                5) echo "█████" ;;
            esac ;;
        1)
            case "$line" in
                1) echo "  ██ " ;;
                2) echo " ███ " ;;
                3) echo "  ██ " ;;
                4) echo "  ██ " ;;
                5) echo "█████" ;;
            esac ;;
        2)
            case "$line" in
                1) echo "█████" ;;
                2) echo "    █" ;;
                3) echo "█████" ;;
                4) echo "█    " ;;
                5) echo "█████" ;;
            esac ;;
        3)
            case "$line" in
                1) echo "█████" ;;
                2) echo "    █" ;;
                3) echo " ████" ;;
                4) echo "    █" ;;
                5) echo "█████" ;;
            esac ;;
        4)
            case "$line" in
                1) echo "█   █" ;;
                2) echo "█   █" ;;
                3) echo "█████" ;;
                4) echo "    █" ;;
                5) echo "    █" ;;
            esac ;;
        5)
            case "$line" in
                1) echo "█████" ;;
                2) echo "█    " ;;
                3) echo "█████" ;;
                4) echo "    █" ;;
                5) echo "█████" ;;
            esac ;;
        6)
            case "$line" in
                1) echo "█████" ;;
                2) echo "█    " ;;
                3) echo "█████" ;;
                4) echo "█   █" ;;
                5) echo "█████" ;;
            esac ;;
        7)
            case "$line" in
                1) echo "█████" ;;
                2) echo "    █" ;;
                3) echo "   █ " ;;
                4) echo "  █  " ;;
                5) echo "  █  " ;;
            esac ;;
        8)
            case "$line" in
                1) echo "█████" ;;
                2) echo "█   █" ;;
                3) echo "█████" ;;
                4) echo "█   █" ;;
                5) echo "█████" ;;
            esac ;;
        9)
            case "$line" in
                1) echo "█████" ;;
                2) echo "█   █" ;;
                3) echo "█████" ;;
                4) echo "    █" ;;
                5) echo "█████" ;;
            esac ;;
        :)
            if [ "$show_colon" -eq 1 ]; then
                case "$line" in
                    1|3|5) echo " " ;;
                    2|4)   echo "█" ;;
                esac
            else
                echo " "
            fi ;;
        " ") echo "  " ;;
        *) echo "     " ;;
    esac
}

# Style 2: Tech Slender (3 lines tall)
get_tech_glyph() {
    local char="$1"
    local line="$2"
    local show_colon="$3"
    case "$char" in
        0) [ "$line" -eq 1 ] && echo "┌─┐" || { [ "$line" -eq 2 ] && echo "│ │" || echo "└─┘"; } ;;
        1) [ "$line" -eq 1 ] && echo " ┐ " || { [ "$line" -eq 2 ] && echo " │ " || echo " ┴ "; } ;;
        2) [ "$line" -eq 1 ] && echo "┌─┐" || { [ "$line" -eq 2 ] && echo "┌─┘" || echo "└──"; } ;;
        3) [ "$line" -eq 1 ] && echo "┌─┐" || { [ "$line" -eq 2 ] && echo " ─┤" || echo "└─┘"; } ;;
        4) [ "$line" -eq 1 ] && echo "│ │" || { [ "$line" -eq 2 ] && echo "└─┤" || echo "  │"; } ;;
        5) [ "$line" -eq 1 ] && echo "┌──" || { [ "$line" -eq 2 ] && echo "└─┐" || echo "──┘"; } ;;
        6) [ "$line" -eq 1 ] && echo "┌──" || { [ "$line" -eq 2 ] && echo "├─┐" || echo "└─┘"; } ;;
        7) [ "$line" -eq 1 ] && echo "──┐" || { [ "$line" -eq 2 ] && echo "  │" || echo "  │"; } ;;
        8) [ "$line" -eq 1 ] && echo "┌─┐" || { [ "$line" -eq 2 ] && echo "├─┤" || echo "└─┘"; } ;;
        9) [ "$line" -eq 1 ] && echo "┌─┐" || { [ "$line" -eq 2 ] && echo "└─┤" || echo "──┘"; } ;;
        :)
            if [ "$show_colon" -eq 1 ]; then
                [ "$line" -eq 1 ] && echo " " || { [ "$line" -eq 2 ] && echo "•" || echo "•"; }
            else
                echo " "
            fi ;;
        " ") echo " " ;;
        *) echo "   " ;;
    esac
}

# Get line of glyph based on current font style
get_glyph_line() {
    local char="$1"
    local line="$2"
    local show_colon="$3"
    case "$FONT_STYLE" in
        0) get_classic_glyph "$char" "$line" "$show_colon" ;;
        1) get_block_glyph "$char" "$line" "$show_colon" ;;
        2) get_tech_glyph "$char" "$line" "$show_colon" ;;
    esac
}

get_glyph_height() {
    case "$FONT_STYLE" in
        0) echo 3 ;;
        1) echo 5 ;;
        2) echo 3 ;;
    esac
}

# ------------------------------------------------------------------------------
# Render Frame
# ------------------------------------------------------------------------------
render_clock() {
    local blink_state="$1"

    get_theme_colors
    local height
    height=$(get_glyph_height)

    # 1. Fetch current time and date in a single Unix date call
    local time_24 time_12 ampm_val day_name date_val
    IFS="|" read -r time_24 time_12 ampm_val day_name date_val <<< "$(date "+%H:%M:%S|%I:%M:%S|%p|%A|%d %B %Y")"

    local time_str ampm_str=""
    if [ "$FORMAT_12H" -eq 1 ]; then
        if [ "$SHOW_SECONDS" -eq 1 ]; then
            time_str="$time_12"
        else
            time_str="${time_12:0:5}"
        fi
        ampm_str="$ampm_val"
    else
        if [ "$SHOW_SECONDS" -eq 1 ]; then
            time_str="$time_24"
        else
            time_str="${time_24:0:5}"
        fi
    fi

    # 2. Build multi-line ASCII output
    local lines=()
    local colon_visible=1
    if [ "$BLINK_COLON" -eq 1 ] && [ "$blink_state" -eq 0 ]; then
        colon_visible=0
    fi

    for ((l=1; l<=height; l++)); do
        local current_row=""
        local len=${#time_str}
        for ((i=0; i<len; i++)); do
            local ch="${time_str:$i:1}"
            local g
            g=$(get_glyph_line "$ch" "$l" "$colon_visible")
            if [ "$ch" = ":" ]; then
                current_row="${current_row} ${COLOR_COLON}${g}${COLOR_DIGIT} "
            else
                current_row="${current_row}${g} "
            fi
        done
        lines[l]="${current_row% }"
    done

    # Calculate exact display column width of clock digits/colons
    local glyph_w=3
    [ "$FONT_STYLE" -eq 1 ] && glyph_w=5

    local inner_width=0
    for ((i=0; i<${#time_str}; i++)); do
        local ch="${time_str:$i:1}"
        if [ "$ch" = ":" ]; then
            inner_width=$(( inner_width + 3 ))
        elif [ "$ch" = " " ]; then
            [ "$FONT_STYLE" -eq 1 ] && inner_width=$(( inner_width + 3 )) || inner_width=$(( inner_width + 2 ))
        else
            inner_width=$(( inner_width + glyph_w + 1 ))
        fi
    done
    inner_width=$(( inner_width - 1 ))

    # Determine border characters
    local b_tl="" b_tr="" b_bl="" b_br="" b_h="" b_v=""
    case "$BORDER_STYLE" in
        1) # Double Lined
            b_tl="╔" b_tr="╗" b_bl="╚" b_br="╝" b_h="═" b_v="║"
            ;;
        2) # Modern Rounded
            b_tl="╭" b_tr="╮" b_bl="╰" b_br="╯" b_h="─" b_v="│"
            ;;
        3) # Dashed
            b_tl="+" b_tr="+" b_bl="+" b_br="+" b_h="-" b_v="|"
            ;;
        4) # Sharp Solid
            b_tl="┌" b_tr="┐" b_bl="└" b_br="┘" b_h="─" b_v="│"
            ;;
    esac

    local total_content_width total_box_width total_box_height box_start_col
    local border_pad=5
    if [ "$BORDER_STYLE" -gt 0 ]; then
        total_content_width=$(( inner_width + border_pad + border_pad ))
        total_box_width=$(( total_content_width + 2 ))
        total_box_height=$(( height + 2 ))
        box_start_col=$(( (TERM_COLS - total_box_width) / 2 ))
    else
        total_content_width=$inner_width
        total_box_width=$inner_width
        total_box_height=$height
        box_start_col=$(( (TERM_COLS - inner_width) / 2 ))
    fi

    # Calculate vertical spacing
    local date_rows=0
    if [ "$SHOW_DATE" -eq 1 ]; then
        date_rows=3
    elif [ "$SHOW_DATE" -eq 2 ]; then
        date_rows=2
    fi

    local total_full_height=$(( total_box_height + date_rows ))
    local start_row=$(( (TERM_ROWS - total_full_height) / 2 ))
    [ "$start_row" -lt 1 ] && start_row=1
    [ "$box_start_col" -lt 1 ] && box_start_col=1

    local current_cursor_row=$start_row

    # 3. Draw Date (if enabled)
    if [ "$SHOW_DATE" -eq 1 ]; then
        local date_col=$(( (TERM_COLS - ${#date_val}) / 2 ))
        [ "$date_col" -lt 1 ] && date_col=1
        printf "%s[%d;%dH%s[2K%s%s%s" "$ESC" "$current_cursor_row" "$date_col" "$ESC" "$COLOR_DATE_SUB" "$date_val" "$COLOR_RESET"
        current_cursor_row=$((current_cursor_row + 1))

        local day_name_upper
        day_name_upper=$(echo "$day_name" | tr "[:lower:]" "[:upper:]")
        local spaced_day=""
        for ((i=0; i<${#day_name_upper}; i++)); do
            spaced_day="${spaced_day}${day_name_upper:$i:1} "
        done
        spaced_day="${spaced_day% }"
        local day_col=$(( (TERM_COLS - ${#spaced_day}) / 2 ))
        [ "$day_col" -lt 1 ] && day_col=1
        printf "%s[%d;%dH%s[2K%s%s%s" "$ESC" "$current_cursor_row" "$day_col" "$ESC" "$COLOR_DATE" "$spaced_day" "$COLOR_RESET"
        current_cursor_row=$((current_cursor_row + 2))
    elif [ "$SHOW_DATE" -eq 2 ]; then
        local compact_str="${day_name}, ${date_val}"
        local date_col=$(( (TERM_COLS - ${#compact_str}) / 2 ))
        [ "$date_col" -lt 1 ] && date_col=1
        printf "%s[%d;%dH%s[2K%s%s%s" "$ESC" "$current_cursor_row" "$date_col" "$ESC" "$COLOR_DATE" "$compact_str" "$COLOR_RESET"
        current_cursor_row=$((current_cursor_row + 2))
    fi

    # 4. Draw Top Border (if border enabled)
    if [ "$BORDER_STYLE" -gt 0 ]; then
        local border_line=""
        for ((b=0; b<total_content_width; b++)); do
            border_line="${border_line}${b_h}"
        done
        local top_border="${b_tl}${border_line}${b_tr}"
        local bot_border="${b_bl}${border_line}${b_br}"

        printf "%s[%d;%dH%s[2K%s%s%s" "$ESC" "$current_cursor_row" "$box_start_col" "$ESC" "$COLOR_BORDER" "$top_border" "$COLOR_RESET"
        current_cursor_row=$((current_cursor_row + 1))
    fi

    # 5. Draw Clock Rows
    for ((l=1; l<=height; l++)); do
        local row_content="${lines[l]}"
        local side_text=""

        if [ "$FORMAT_12H" -eq 1 ] && [ "$l" -eq "$height" ]; then
            side_text="  ${COLOR_AMPM}${ampm_str}${COLOR_RESET}"
        fi

        if [ "$BORDER_STYLE" -gt 0 ]; then
            local border_side_pad="     "
            if [ "$FORMAT_12H" -eq 1 ] && [ "$l" -eq "$height" ]; then
                border_side_pad="  ${COLOR_AMPM}${ampm_str}${COLOR_RESET} "
            fi

            printf "%s[%d;%dH%s[2K%s%s%s     %s%s%s%s%s" \
                "$ESC" "$current_cursor_row" "$box_start_col" "$ESC" \
                "$COLOR_BORDER" "$b_v" "$COLOR_RESET" \
                "${COLOR_DIGIT}${row_content}${COLOR_RESET}" \
                "$border_side_pad" \
                "$COLOR_BORDER" "$b_v" "$COLOR_RESET"
        else
            printf "%s[%d;%dH%s[2K%s%s" \
                "$ESC" "$current_cursor_row" "$box_start_col" "$ESC" \
                "${COLOR_DIGIT}${row_content}${COLOR_RESET}" \
                "$side_text"
        fi
        current_cursor_row=$((current_cursor_row + 1))
    done

    # 6. Draw Bottom Border (if border enabled)
    if [ "$BORDER_STYLE" -gt 0 ]; then
        printf "%s[%d;%dH%s[2K%s%s%s" "$ESC" "$current_cursor_row" "$box_start_col" "$ESC" "$COLOR_BORDER" "$bot_border" "$COLOR_RESET"
        current_cursor_row=$((current_cursor_row + 1))
    fi

    # 7. Clean Muted Grey Controls Bar
    if [ "$SHOW_HELP" -eq 1 ]; then
        local help_msg="[T] 12/24H   [S] Sec   [C] Color: $THEME_NAME   [F] Font   [B] Border   [D] Date   [H] Close   [Q] Quit"
        local help_col=$(( (TERM_COLS - ${#help_msg}) / 2 ))
        [ "$help_col" -lt 1 ] && help_col=1
        printf "%s[%d;%dH%s[2K%s%s%s" "$ESC" "$((TERM_ROWS - 1))" "$help_col" "$ESC" "$COLOR_DIM" "$help_msg" "$COLOR_RESET"
    else
        local hint="[H] Controls   [Q] Quit"
        local hint_col=$(( (TERM_COLS - ${#hint}) / 2 ))
        [ "$hint_col" -lt 1 ] && hint_col=1
        printf "%s[%d;%dH%s[2K%s%s%s" "$ESC" "$((TERM_ROWS - 1))" "$hint_col" "$ESC" "$COLOR_DIM" "$hint" "$COLOR_RESET"
    fi
}

# ------------------------------------------------------------------------------
# Input Processing
# ------------------------------------------------------------------------------
process_key() {
    local key="$1"
    [ -z "$key" ] && return 1

    if [ "$SHOW_HELP" -eq 1 ]; then
        case "$key" in
            h|H|$'\e'|" "|$'\n')
                SHOW_HELP=0
                printf "%s[2J" "$ESC"
                return 0
                ;;
        esac
    fi

    case "$key" in
        q|Q) cleanup ;;
        $'\e') cleanup ;;
        t|T) FORMAT_12H=$(( 1 - FORMAT_12H )); printf "%s[2J" "$ESC" ;;
        s|S) SHOW_SECONDS=$(( 1 - SHOW_SECONDS )); printf "%s[2J" "$ESC" ;;
        d|D) SHOW_DATE=$(( (SHOW_DATE + 1) % 3 )); printf "%s[2J" "$ESC" ;;
        c|C) COLOR_THEME=$(( (COLOR_THEME + 1) % 6 )) ;; # Instant recolor without screen clear
        f|F) FONT_STYLE=$(( (FONT_STYLE + 1) % 3 )); printf "%s[2J" "$ESC" ;;
        b|B) BORDER_STYLE=$(( (BORDER_STYLE + 1) % 5 )); printf "%s[2J" "$ESC" ;;
        h|H|\?) SHOW_HELP=$(( 1 - SHOW_HELP )); printf "%s[2J" "$ESC" ;;
        *) return 1 ;;
    esac
    return 0
}

# ------------------------------------------------------------------------------
# Main Event Loop
# ------------------------------------------------------------------------------
update_term_size
printf "%s[2J" "$ESC"

blink=1
tick=0
render_clock "$blink"

while true; do
    raw_in=$(dd bs=10 count=1 2>/dev/null || true)
    if [ -n "$raw_in" ]; then
        if process_key "$raw_in"; then
            render_clock "$blink"
            tick=0
        fi
    fi

    sleep 0.05
    tick=$((tick + 1))

    # Every 10 ticks (0.5 seconds), update time and blink
    if [ "$tick" -ge 10 ]; then
        tick=0
        blink=$(( 1 - blink ))
        render_clock "$blink"
    fi
done
