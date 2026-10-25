#!/usr/bin/env python3
"""
Generate a realistic, high-resolution desktop composition preview for the Night Owl theme.
Features:
- Night Owl nocturnal wallpaper backdrop
- Top status bar with zero-padded workspace labels (01 02 03 04 05), owl launcher, clock, and metrics
- Tiled/floating Ghostty terminal with active cyan/blue gradient border, fastfetch, and code snippet
- btop / system island popover in Night Owl palette
- Clean color palette swatch legend showing canonical colors and hex codes
"""

import os
import subprocess

def create_preview_svg(width=1920, height=1080):
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}" font-family="'JetBrainsMono Nerd Font', 'Inter', monospace">
    <defs>
        <!-- Gradients -->
        <linearGradient id="activeBorderGrad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#7FDBCA" />
            <stop offset="100%" stop-color="#82AAFF" />
        </linearGradient>

        <linearGradient id="inactiveBorderGrad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#1D3B53" />
            <stop offset="100%" stop-color="#112E47" />
        </linearGradient>

        <filter id="winShadow" x="-10%" y="-10%" width="130%" height="130%">
            <feDropShadow dx="0" dy="12" stdDeviation="16" flood-color="#010E1A" flood-opacity="0.85" />
        </filter>

        <filter id="subtleGlow" x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur stdDeviation="8" result="blur" />
            <feComposite in="SourceGraphic" in2="blur" operator="over" />
        </filter>
    </defs>

    <!-- 1. Background Wallpaper Reference -->
    <image href="/home/michal/Projects/Sakurazuki/themes/night-owl/assets/wallpapers/night-owl.png" width="{width}" height="{height}" preserveAspectRatio="xMidYMid slice" />

    <!-- 2. Dark Bar Backdrop Overlay -->
    <rect x="0" y="0" width="{width}" height="32" fill="#011627" fill-opacity="0.94" />
    <line x1="0" y1="32" x2="{width}" y2="32" stroke="#1D3B53" stroke-width="1" stroke-opacity="0.7" />

    <!-- TOP BAR: Left Island (Workspaces & Owl) -->
    <g transform="translate(14, 3)">
        <rect width="260" height="26" rx="13" fill="#E6011627" stroke="#1D3B53" stroke-width="1" />
        <!-- Owl Launcher -->
        <circle cx="16" cy="13" r="10" fill="#7FDBCA" fill-opacity="0.18" />
        <text x="16" y="18" font-size="12" text-anchor="middle">🦉</text>
        <line x1="32" y1="7" x2="32" y2="19" stroke="#D6DEEB" stroke-width="1" stroke-opacity="0.2" />

        <!-- Workspaces 01..05 -->
        <!-- 01 Active -->
        <rect x="38" y="3" width="28" height="20" rx="6" fill="#7FDBCA" />
        <text x="52" y="17" font-size="10" font-weight="bold" fill="#011627" text-anchor="middle">01</text>

        <!-- 02 Occupied -->
        <rect x="70" y="3" width="28" height="20" rx="6" fill="#7FDBCA" fill-opacity="0.18" />
        <text x="84" y="17" font-size="10" fill="#D6DEEB" text-anchor="middle">02</text>

        <!-- 03 Inactive -->
        <rect x="102" y="3" width="28" height="20" rx="6" fill="transparent" />
        <text x="116" y="17" font-size="10" fill="#637777" text-anchor="middle">03</text>

        <!-- 04 Inactive -->
        <rect x="134" y="3" width="28" height="20" rx="6" fill="transparent" />
        <text x="148" y="17" font-size="10" fill="#637777" text-anchor="middle">04</text>

        <!-- 05 Inactive -->
        <rect x="166" y="3" width="28" height="20" rx="6" fill="transparent" />
        <text x="180" y="17" font-size="10" fill="#637777" text-anchor="middle">05</text>
    </g>

    <!-- TOP BAR: Center Island (Clock & Weather) -->
    <g transform="translate({int(width/2 - 130)}, 3)">
        <rect width="260" height="26" rx="13" fill="#E60B253A" stroke="#1D3B53" stroke-width="1" />
        <text x="80" y="17" font-size="11" font-weight="bold" fill="#82AAFF" text-anchor="middle">Mon Oct 26 · 01:05</text>
        <line x1="160" y1="7" x2="160" y2="19" stroke="#D6DEEB" stroke-width="1" stroke-opacity="0.2" />
        <text x="205" y="17" font-size="11" fill="#7FDBCA" text-anchor="middle">󰖐 21°C</text>
    </g>

    <!-- TOP BAR: Right Island (System Metrics & Controls) -->
    <g transform="translate({width - 320}, 3)">
        <rect width="306" height="26" rx="13" fill="#E60B253A" stroke="#1D3B53" stroke-width="1" />
        <text x="25" y="17" font-size="11" fill="#C792EA" text-anchor="middle">󰍛 14%</text>
        <text x="75" y="17" font-size="11" fill="#82AAFF" text-anchor="middle">󰘚 38%</text>
        <text x="125" y="17" font-size="11" fill="#ADDB67" text-anchor="middle">󰤨 WiFi</text>
        <text x="175" y="17" font-size="11" fill="#82AAFF" text-anchor="middle">󰕾 80%</text>
        <text x="230" y="17" font-size="11" fill="#7FDBCA" text-anchor="middle">󰁹 95%</text>
        <text x="282" y="17" font-size="12" fill="#FF6363" text-anchor="middle">⏻</text>
    </g>

    <!-- 3. MAIN WINDOW: Ghostty Terminal (Focused with Active Teal/Blue Gradient Border) -->
    <g transform="translate(60, 68)" filter="url(#winShadow)">
        <!-- Outer Border Rect -->
        <rect width="980" height="640" rx="12" fill="url(#activeBorderGrad)" />
        <!-- Inner Window Content -->
        <rect x="2" y="2" width="976" height="636" rx="10" fill="#011627" fill-opacity="0.95" />

        <!-- Terminal Header -->
        <g transform="translate(18, 16)">
            <circle cx="8" cy="8" r="6" fill="#FF6363" />
            <circle cx="28" cy="8" r="6" fill="#ECC48D" />
            <circle cx="48" cy="8" r="6" fill="#ADDB67" />
            <text x="470" y="12" font-size="11" fill="#80A4C2" text-anchor="middle">michal@omarchy: ~/Projects/Night-Owl (ghostty)</text>
        </g>
        <line x1="2" y1="42" x2="978" y2="42" stroke="#1D3B53" stroke-width="1" />

        <!-- Terminal Body: fastfetch & neovim snippet -->
        <g transform="translate(24, 66)">
            <!-- Left: fastfetch logo & stats -->
            <text x="0" y="18" font-size="12" fill="#7FDBCA" font-weight="bold">       /\         michal@omarchy</text>
            <text x="0" y="36" font-size="12" fill="#7FDBCA" font-weight="bold">      /  \        --------------</text>
            <text x="0" y="54" font-size="12" fill="#82AAFF">     /\   \       OS:      Omarchy Linux x86_64</text>
            <text x="0" y="72" font-size="12" fill="#82AAFF">    /      \      Host:    Developer Workstation</text>
            <text x="0" y="90" font-size="12" fill="#82AAFF">   /   ,,   \     Kernel:  Linux 6.12.9-arch1</text>
            <text x="0" y="108" font-size="12" fill="#C792EA">  /   |  |  -\    WM:      Hyprland 0.56.2 (Wayland)</text>
            <text x="0" y="126" font-size="12" fill="#C792EA"> /_-''    ''-_\   Theme:   Night Owl [GTK3/4, Quickshell]</text>
            <text x="0" y="144" font-size="12" fill="#C792EA">                  Icons:   Yaru-blue-dark</text>
            <text x="0" y="162" font-size="12" fill="#D6DEEB">                  Terminal: Ghostty</text>
            <text x="0" y="180" font-size="12" fill="#D6DEEB">                  Workspaces: 01 02 03 04 05 06 07 08 09 10</text>
            <text x="0" y="198" font-size="12" fill="#D6DEEB">                  Memory:  4.2 GiB / 32.0 GiB</text>

            <!-- Color test blocks -->
            <rect x="0" y="222" width="20" height="12" fill="#011627" stroke="#1D3B53" stroke-width="1" />
            <rect x="24" y="222" width="20" height="12" fill="#FF6363" />
            <rect x="48" y="222" width="20" height="12" fill="#ADDB67" />
            <rect x="72" y="222" width="20" height="12" fill="#ECC48D" />
            <rect x="96" y="222" width="20" height="12" fill="#82AAFF" />
            <rect x="120" y="222" width="20" height="12" fill="#C792EA" />
            <rect x="144" y="222" width="20" height="12" fill="#7FDBCA" />
            <rect x="168" y="222" width="20" height="12" fill="#D6DEEB" />

            <!-- Code snippet in Night Owl syntax highlighting -->
            <g transform="translate(0, 260)">
                <text x="0" y="16" font-size="12" fill="#637777">// Night Owl Desktop Engine — Sarah Drasner Palette</text>
                <text x="0" y="38" font-size="12"><tspan fill="#C792EA">const</tspan> <tspan fill="#7FDBCA">palette</tspan> = <tspan fill="#C792EA">await</tspan> <tspan fill="#82AAFF">loadTheme</tspan>(<tspan fill="#ECC48D">"night-owl"</tspan>);</text>
                <text x="0" y="60" font-size="12"><tspan fill="#C792EA">const</tspan> <tspan fill="#7FDBCA">workspaces</tspan> = <tspan fill="#7FDBCA">palette</tspan>.<tspan fill="#82AAFF">formatLabels</tspan>({{ <tspan fill="#7FDBCA">zeroPad</tspan>: <tspan fill="#FF6363">true</tspan> }});</text>
                <text x="0" y="82" font-size="12"><tspan fill="#637777">// Result: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10"]</tspan></text>
                <text x="0" y="104" font-size="12"><tspan fill="#82AAFF">applyCompositorBorders</tspan>({{ <tspan fill="#7FDBCA">active</tspan>: <tspan fill="#ECC48D">"#7FDBCA #82AAFF 45deg"</tspan> }});</text>
                <text x="0" y="126" font-size="12"><tspan fill="#ADDB67">console</tspan>.<tspan fill="#82AAFF">log</tspan>(<tspan fill="#ECC48D">"Night Owl active: 🦉 10 workspaces ready"</tspan>);</text>
                
                <text x="0" y="160" font-size="12" fill="#7FDBCA">michal@omarchy:~$ <tspan fill="#D6DEEB">omarchy-theme-switch status</tspan></text>
                <text x="0" y="180" font-size="12" fill="#ADDB67">Currently active theme: Night Owl</text>
                <text x="0" y="200" font-size="12" fill="#7FDBCA">michal@omarchy:~$ <tspan fill="#80A4C2">█</tspan></text>
            </g>
        </g>
    </g>

    <!-- 4. SECONDARY WINDOW: btop System Activity & Resource Overview -->
    <g transform="translate(1080, 80)" filter="url(#winShadow)">
        <rect width="780" height="420" rx="12" fill="url(#inactiveBorderGrad)" />
        <rect x="2" y="2" width="776" height="416" rx="10" fill="#0B253A" fill-opacity="0.95" />

        <g transform="translate(18, 16)">
            <circle cx="8" cy="8" r="6" fill="#1D3B53" />
            <circle cx="28" cy="8" r="6" fill="#1D3B53" />
            <circle cx="48" cy="8" r="6" fill="#1D3B53" />
            <text x="370" y="12" font-size="11" fill="#80A4C2" text-anchor="middle">btop — System Activity (Night Owl)</text>
        </g>
        <line x1="2" y1="42" x2="778" y2="42" stroke="#1D3B53" stroke-width="1" />

        <g transform="translate(24, 60)">
            <!-- CPU Box -->
            <rect x="0" y="0" width="350" height="160" rx="8" fill="#011627" stroke="#C792EA" stroke-width="1" />
            <text x="14" y="22" font-size="11" font-weight="bold" fill="#C792EA">CPU Usage: 14%</text>
            <polyline points="20,130 60,110 110,125 160,85 210,95 260,65 310,75 330,80" fill="none" stroke="#7FDBCA" stroke-width="2" />
            <polyline points="20,140 60,125 110,135 160,110 210,120 260,95 310,105 330,110" fill="none" stroke="#82AAFF" stroke-width="1.5" stroke-dasharray="2,2" />

            <!-- Memory Box -->
            <rect x="374" y="0" width="350" height="160" rx="8" fill="#011627" stroke="#ADDB67" stroke-width="1" />
            <text x="388" y="22" font-size="11" font-weight="bold" fill="#ADDB67">Memory: 4.2 GiB / 32.0 GiB (13%)</text>
            <rect x="388" y="45" width="320" height="14" rx="7" fill="#1D3B53" />
            <rect x="388" y="45" width="70" height="14" rx="7" fill="#7FDBCA" />
            <text x="388" y="85" font-size="10" fill="#D6DEEB">Swap: 0 B / 8.0 GiB</text>
            <text x="388" y="105" font-size="10" fill="#D6DEEB">Disks: nvme0n1 (1.8 TB / 2.0 TB free)</text>
            <text x="388" y="125" font-size="10" fill="#80A4C2">Processes: 182 | Threads: 940</text>

            <!-- Network Box -->
            <rect x="0" y="174" width="724" height="150" rx="8" fill="#011627" stroke="#7FDBCA" stroke-width="1" />
            <text x="14" y="196" font-size="11" font-weight="bold" fill="#7FDBCA">Network &amp; Audio IO</text>
            <text x="14" y="220" font-size="10" fill="#D6DEEB">wlan0 (Connected: 5 GHz, -48 dBm)  ▲ 2.4 MB/s   ▼ 18.2 MB/s</text>
            <text x="14" y="240" font-size="10" fill="#82AAFF">PipeWire Sound Server: 48000 Hz, 2ch, Buffer 256 samples</text>
            <text x="14" y="260" font-size="10" fill="#ADDB67">Active Profile: Night Owl Headphones (Balanced)</text>
        </g>
    </g>

    <!-- 5. COLOR PALETTE SWATCH FOOTER STRIP -->
    <g transform="translate(60, 920)" filter="url(#winShadow)">
        <rect width="1800" height="120" rx="14" fill="#011627" fill-opacity="0.94" stroke="#1D3B53" stroke-width="1.5" />
        
        <text x="24" y="32" font-size="13" font-weight="bold" fill="#D6DEEB">Sarah Drasner's Canonical Night Owl Color Hierarchy</text>
        <text x="24" y="52" font-size="10" fill="#80A4C2">Native Omarchy Linux Theme Implementation · Workspaces: 01 02 03 04 05 06 07 08 09 10</text>

        <!-- Swatches -->
        <!-- Background -->
        <g transform="translate(24, 68)">
            <rect width="140" height="34" rx="6" fill="#011627" stroke="#1D3B53" stroke-width="1" />
            <text x="10" y="15" font-size="9" fill="#D6DEEB">Background</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#80A4C2">#011627</text>
        </g>
        <!-- Foreground -->
        <g transform="translate(176, 68)">
            <rect width="140" height="34" rx="6" fill="#D6DEEB" />
            <text x="10" y="15" font-size="9" fill="#011627">Foreground</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#011627">#D6DEEB</text>
        </g>
        <!-- Variables (Teal) -->
        <g transform="translate(328, 68)">
            <rect width="140" height="34" rx="6" fill="#7FDBCA" />
            <text x="10" y="15" font-size="9" fill="#011627">Variables (Teal)</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#011627">#7FDBCA</text>
        </g>
        <!-- Functions (Blue) -->
        <g transform="translate(480, 68)">
            <rect width="140" height="34" rx="6" fill="#82AAFF" />
            <text x="10" y="15" font-size="9" fill="#011627">Functions (Blue)</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#011627">#82AAFF</text>
        </g>
        <!-- Keywords (Purple) -->
        <g transform="translate(632, 68)">
            <rect width="140" height="34" rx="6" fill="#C792EA" />
            <text x="10" y="15" font-size="9" fill="#011627">Keywords (Purple)</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#011627">#C792EA</text>
        </g>
        <!-- Strings (Warm) -->
        <g transform="translate(784, 68)">
            <rect width="140" height="34" rx="6" fill="#ECC48D" />
            <text x="10" y="15" font-size="9" fill="#011627">Strings (Warm)</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#011627">#ECC48D</text>
        </g>
        <!-- Support (Green) -->
        <g transform="translate(936, 68)">
            <rect width="140" height="34" rx="6" fill="#ADDB67" />
            <text x="10" y="15" font-size="9" fill="#011627">Support (Green)</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#011627">#ADDB67</text>
        </g>
        <!-- Numbers (Orange) -->
        <g transform="translate(1088, 68)">
            <rect width="140" height="34" rx="6" fill="#F78C6C" />
            <text x="10" y="15" font-size="9" fill="#011627">Numbers (Orange)</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#011627">#F78C6C</text>
        </g>
        <!-- Constants (Red) -->
        <g transform="translate(1240, 68)">
            <rect width="140" height="34" rx="6" fill="#FF6363" />
            <text x="10" y="15" font-size="9" fill="#011627">Constants (Red)</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#011627">#FF6363</text>
        </g>
        <!-- Invalid (Pink) -->
        <g transform="translate(1392, 68)">
            <rect width="140" height="34" rx="6" fill="#FF2C83" />
            <text x="10" y="15" font-size="9" fill="#FFFFFF">Invalid (Alert)</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#FFFFFF">#FF2C83</text>
        </g>
        <!-- Comments -->
        <g transform="translate(1544, 68)">
            <rect width="140" height="34" rx="6" fill="#637777" />
            <text x="10" y="15" font-size="9" fill="#FFFFFF">Comments</text>
            <text x="10" y="28" font-size="9" font-weight="bold" fill="#FFFFFF">#637777</text>
        </g>
        <!-- Selection -->
        <g transform="translate(1696, 68)">
            <rect width="84" height="34" rx="6" fill="#1D3B53" />
            <text x="8" y="15" font-size="9" fill="#D6DEEB">Selection</text>
            <text x="8" y="28" font-size="9" font-weight="bold" fill="#80A4C2">#1D3B53</text>
        </g>
    </g>
</svg>
'''
    return svg

def main():
    base_dir = "/home/michal/Projects/Sakurazuki/themes/night-owl"
    preview_svg_path = os.path.join(base_dir, "assets", "preview.svg")
    preview_png_path = os.path.join(base_dir, "assets", "preview.png")
    root_preview_path = os.path.join(base_dir, "preview.png")

    svg_content = create_preview_svg(1920, 1080)
    with open(preview_svg_path, "w") as f:
        f.write(svg_content)
    
    subprocess.run(["magick", preview_svg_path, preview_png_path], check=True)
    subprocess.run(["cp", preview_png_path, root_preview_path], check=True)
    print("Preview generated at:", preview_png_path)

if __name__ == "__main__":
    main()
