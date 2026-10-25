#!/usr/bin/env python3
"""
Generate original, high-resolution Night Owl wallpapers matching Sarah Drasner's palette.
Renders SVG with gradients, stars, moon, mountain silhouettes, and owl silhouette.
"""

import math
import os
import random
import subprocess

def create_night_owl_wallpaper_svg(width=2560, height=1440, has_owl=True):
    random.seed(42)  # Deterministic beautiful stars
    
    # Generate stars
    stars_svg = []
    for _ in range(160):
        sx = random.randint(20, width - 20)
        sy = random.randint(20, int(height * 0.65))
        srad = random.choice([0.8, 1.2, 1.6, 2.2])
        sopac = random.choice([0.35, 0.55, 0.75, 0.95])
        color = random.choice(["#D6DEEB", "#82AAFF", "#7FDBCA", "#C792EA"])
        stars_svg.append(f'<circle cx="{sx}" cy="{sy}" r="{srad}" fill="{color}" opacity="{sopac}" />')

    # Constellation lines
    constellations = [
        [(350, 180), (410, 140), (480, 160), (520, 230), (460, 290), (380, 270), (350, 180)],
        [(1950, 220), (2020, 170), (2110, 190), (2180, 260), (2100, 310)]
    ]
    const_svg = []
    for pts in constellations:
        pts_str = " ".join(f"{p[0]},{p[1]}" for p in pts)
        const_svg.append(f'<polyline points="{pts_str}" fill="none" stroke="#82AAFF" stroke-width="0.8" opacity="0.35" stroke-dasharray="3,3" />')
        for p in pts:
            const_svg.append(f'<circle cx="{p[0]}" cy="{p[1]}" r="2.8" fill="#7FDBCA" opacity="0.8" />')

    moon_cx = int(width * 0.72)
    moon_cy = int(height * 0.34)
    moon_r = 135

    owl_elements = ""
    if has_owl:
        # Branch
        branch_path = f"M {int(width*0.18)} {height} Q {int(width*0.28)} {int(height*0.72)} {int(width*0.48)} {int(height*0.70)} Q {int(width*0.56)} {int(height*0.69)} {int(width*0.62)} {int(height*0.72)}"
        branch_svg = f'''
        <path d="{branch_path}" fill="none" stroke="#010E1A" stroke-width="38" stroke-linecap="round"/>
        <path d="{branch_path}" fill="none" stroke="#0B253A" stroke-width="14" stroke-linecap="round" opacity="0.4"/>
        '''

        # Perched Owl on branch around (width*0.42, height*0.68)
        ox = int(width * 0.42)
        oy = int(height * 0.65)
        owl_svg = f'''
        <!-- Owl Silhouette -->
        <g id="owl">
            <!-- Tail -->
            <path d="M {ox-15} {oy+45} L {ox-8} {oy+110} L {ox+8} {oy+110} L {ox+15} {oy+45} Z" fill="#010E1A" />
            
            <!-- Body -->
            <ellipse cx="{ox}" cy="{oy+30}" rx="32" ry="48" fill="#010E1A" />
            <!-- Soft plumage highlight -->
            <ellipse cx="{ox}" cy="{oy+30}" rx="24" ry="40" fill="#0B253A" opacity="0.3" />
            
            <!-- Wings -->
            <path d="M {ox-30} {oy+10} Q {ox-42} {oy+55} {ox-20} {oy+80} Q {ox-10} {oy+45} {ox-28} {oy+15} Z" fill="#010E1A" />
            <path d="M {ox+30} {oy+10} Q {ox+42} {oy+55} {ox+20} {oy+80} Q {ox+10} {oy+45} {ox+28} {oy+15} Z" fill="#010E1A" />
            
            <!-- Head -->
            <circle cx="{ox}" cy="{oy-20}" r="28" fill="#010E1A" />
            
            <!-- Feather tufts (ear tufts) -->
            <polygon points="{ox-24},{oy-25} {ox-30},{oy-52} {ox-12},{oy-38}" fill="#010E1A" />
            <polygon points="{ox+24},{oy-25} {ox+30},{oy-52} {ox+12},{oy-38}" fill="#010E1A" />
            
            <!-- Facial disc -->
            <circle cx="{ox-10}" cy="{oy-18}" r="12" fill="#051C30" opacity="0.6" />
            <circle cx="{ox+10}" cy="{oy-18}" r="12" fill="#051C30" opacity="0.6" />
            
            <!-- Eyes (Night Owl luminous cyan) -->
            <circle cx="{ox-10}" cy="{oy-18}" r="5.5" fill="#7FDBCA" />
            <circle cx="{ox-10}" cy="{oy-18}" r="2.5" fill="#011627" />
            <circle cx="{ox-11}" cy="{oy-19}" r="1.2" fill="#FFFFFF" opacity="0.9" />

            <circle cx="{ox+10}" cy="{oy-18}" r="5.5" fill="#7FDBCA" />
            <circle cx="{ox+10}" cy="{oy-18}" r="2.5" fill="#011627" />
            <circle cx="{ox+9}" cy="{oy-19}" r="1.2" fill="#FFFFFF" opacity="0.9" />
            
            <!-- Beak -->
            <polygon points="{ox-3},{oy-12} {ox+3},{oy-12} {ox},{oy-4}" fill="#ECC48D" />
            
            <!-- Talons clutching branch -->
            <ellipse cx="{ox-14}" cy="{oy+74}" rx="5" ry="3" fill="#ECC48D" />
            <ellipse cx="{ox-8}" cy="{oy+75}" rx="5" ry="3" fill="#ECC48D" />
            <ellipse cx="{ox+8}" cy="{oy+75}" rx="5" ry="3" fill="#ECC48D" />
            <ellipse cx="{ox+14}" cy="{oy+74}" rx="5" ry="3" fill="#ECC48D" />
        </g>
        '''
        owl_elements = branch_svg + owl_svg

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
    <defs>
        <!-- Night Sky Gradient -->
        <linearGradient id="skyGrad" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stop-color="#010E1A" />
            <stop offset="35%" stop-color="#011627" />
            <stop offset="70%" stop-color="#042038" />
            <stop offset="100%" stop-color="#072C4C" />
        </linearGradient>

        <!-- Moon Glow Radiance -->
        <radialGradient id="moonAura" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stop-color="#7FDBCA" stop-opacity="0.32" />
            <stop offset="45%" stop-color="#82AAFF" stop-opacity="0.16" />
            <stop offset="75%" stop-color="#C792EA" stop-opacity="0.06" />
            <stop offset="100%" stop-color="#011627" stop-opacity="0" />
        </radialGradient>

        <!-- Moon Face Gradient -->
        <radialGradient id="moonFace" cx="42%" cy="42%" r="58%">
            <stop offset="0%" stop-color="#FFFFFF" />
            <stop offset="55%" stop-color="#E2E8F0" />
            <stop offset="85%" stop-color="#D6DEEB" />
            <stop offset="100%" stop-color="#80A4C2" />
        </radialGradient>

        <!-- Distant Fog Gradient -->
        <linearGradient id="fogGrad" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stop-color="#7FDBCA" stop-opacity="0" />
            <stop offset="50%" stop-color="#0B253A" stop-opacity="0.35" />
            <stop offset="100%" stop-color="#011627" stop-opacity="0.8" />
        </linearGradient>
    </defs>

    <!-- 1. Background Sky -->
    <rect width="{width}" height="{height}" fill="url(#skyGrad)" />

    <!-- 2. Celestial Moon Glow Halo -->
    <circle cx="{moon_cx}" cy="{moon_cy}" r="{moon_r * 3.5}" fill="url(#moonAura)" />
    <circle cx="{moon_cx}" cy="{moon_cy}" r="{moon_r * 2.0}" fill="url(#moonAura)" />

    <!-- 3. Twinkling Stars & Constellations -->
    {"".join(stars_svg)}
    {"".join(const_svg)}

    <!-- 4. Luminous Full Moon -->
    <circle cx="{moon_cx}" cy="{moon_cy}" r="{moon_r}" fill="url(#moonFace)" />
    <!-- Subtle Maria / Lunar Craters -->
    <circle cx="{moon_cx - 35}" cy="{moon_cy - 20}" r="26" fill="#80A4C2" opacity="0.18" />
    <circle cx="{moon_cx + 40}" cy="{moon_cy + 25}" r="34" fill="#80A4C2" opacity="0.16" />
    <circle cx="{moon_cx - 15}" cy="{moon_cy + 45}" r="22" fill="#80A4C2" opacity="0.14" />
    <circle cx="{moon_cx + 20}" cy="{moon_cy - 45}" r="18" fill="#80A4C2" opacity="0.15" />

    <!-- 5. Distant Mountain Range (Soft Blue) -->
    <path d="M 0 {int(height*0.78)} 
             Q {int(width*0.15)} {int(height*0.58)} {int(width*0.32)} {int(height*0.74)}
             T {int(width*0.65)} {int(height*0.68)}
             T {int(width*0.88)} {int(height*0.62)}
             L {width} {int(height*0.72)} L {width} {height} L 0 {height} Z" 
          fill="#05243E" opacity="0.55" />

    <!-- 6. Midground Mountain Range (Deep Midnight Teal) -->
    <path d="M 0 {int(height*0.84)} 
             Q {int(width*0.22)} {int(height*0.70)} {int(width*0.45)} {int(height*0.82)}
             T {int(width*0.78)} {int(height*0.75)}
             L {width} {int(height*0.80)} L {width} {height} L 0 {height} Z" 
          fill="#03182A" opacity="0.80" />

    <!-- 7. Ambient Fog / Horizon Wash -->
    <rect y="{int(height*0.62)}" width="{width}" height="{int(height*0.38)}" fill="url(#fogGrad)" />

    <!-- 8. Foreground Ridge (Darkest Solid Navy) -->
    <path d="M 0 {int(height*0.90)} 
             Q {int(width*0.30)} {int(height*0.82)} {int(width*0.60)} {int(height*0.92)}
             T {width} {int(height*0.86)}
             L {width} {height} L 0 {height} Z" 
          fill="#010E1A" />

    <!-- 9. Owl and Perch -->
    {owl_elements}

    <!-- 10. Top Bar Protection Vignette: Ensure top 36px stays cleanly dark (#011627) -->
    <rect width="{width}" height="42" fill="#011627" opacity="0.5" />
</svg>
'''
    return svg

def main():
    base_dir = "/home/michal/Projects/Sakurazuki/themes/night-owl"
    wp_dir = os.path.join(base_dir, "assets", "wallpapers")
    bg_dir = os.path.join(base_dir, "backgrounds")
    os.makedirs(wp_dir, exist_ok=True)
    os.makedirs(bg_dir, exist_ok=True)

    # 1. Main Night Owl Wallpaper (with Owl)
    svg_main = create_night_owl_wallpaper_svg(2560, 1440, has_owl=True)
    svg_main_path = os.path.join(wp_dir, "night-owl.svg")
    with open(svg_main_path, "w") as f:
        f.write(svg_main)
    
    png_main_path = os.path.join(wp_dir, "night-owl.png")
    subprocess.run(["magick", svg_main_path, png_main_path], check=True)
    subprocess.run(["cp", png_main_path, os.path.join(bg_dir, "night-owl.png")], check=True)
    print("Created:", png_main_path)

    # 2. Minimalist Night Owl Wallpaper (Nocturnal moon and mountains)
    svg_min = create_night_owl_wallpaper_svg(2560, 1440, has_owl=False)
    svg_min_path = os.path.join(wp_dir, "night-owl-minimal.svg")
    with open(svg_min_path, "w") as f:
        f.write(svg_min)
    
    png_min_path = os.path.join(wp_dir, "night-owl-minimal.png")
    subprocess.run(["magick", svg_min_path, png_min_path], check=True)
    subprocess.run(["cp", png_min_path, os.path.join(bg_dir, "night-owl-minimal.png")], check=True)
    print("Created:", png_min_path)

if __name__ == "__main__":
    main()
