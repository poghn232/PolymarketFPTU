import math
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from test_svg_parser import parse_svg_path, icon_d
from PIL import Image, ImageDraw, ImageFilter

def render_official_polymarket_fpt(size=1024, is_foreground_only=False):
    # Render at 4x resolution for super-sampled antialiasing
    scale = 4
    w = size * scale
    h = size * scale
    
    subpaths = parse_svg_path(icon_d)
    # Bounding box of original SVG:
    # X: ~ -0.126 to 136.267 (width ~ 136.4)
    # Y: ~ 1.0 to 166.99 (height ~ 166.0)
    orig_w = 136.4
    orig_h = 166.0
    orig_ox = -0.126
    orig_oy = 1.0
    
    # We want the icon glyph to fit nicely in the center:
    # For Android adaptive foreground: glyph diameter ~ 60% of canvas
    # For standalone icon: glyph diameter ~ 70% of canvas
    target_h = h * (0.58 if is_foreground_only else 0.68)
    scale_factor = target_h / orig_h
    target_w = orig_w * scale_factor
    
    offset_x = (w - target_w) / 2.0 - (orig_ox * scale_factor)
    offset_y = (h - target_h) / 2.0 - (orig_oy * scale_factor)
    
    def transform_pt(pt):
        return (offset_x + pt[0] * scale_factor, offset_y + pt[1] * scale_factor)
    
    transformed_subpaths = [[transform_pt(pt) for pt in sp] for sp in subpaths]
    
    # Create canvas
    if is_foreground_only:
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    else:
        # Deep premium slate/dark background like Polymarket
        img = Image.new("RGBA", (w, h), (15, 23, 42, 255)) # #0F172A
        
        # Add subtle radial FPT Orange glow behind the logo
        glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        g_draw = ImageDraw.Draw(glow)
        cx, cy = w // 2, h // 2
        r_glow = int(target_h * 0.55)
        g_draw.ellipse(
            (cx - r_glow, cy - r_glow, cx + r_glow, cy + r_glow),
            fill=(243, 112, 33, 70)
        )
        glow = glow.filter(ImageFilter.GaussianBlur(radius=int(r_glow * 0.45)))
        img = Image.alpha_composite(img, glow)
        
        # Subtle rounded squircle frame
        frame_draw = ImageDraw.Draw(img)
        corner_r = int(w * 0.22)
        frame_box = (int(w * 0.035), int(h * 0.035), int(w * 0.965), int(h * 0.965))
        frame_draw.rounded_rectangle(
            frame_box,
            radius=corner_r,
            outline=(243, 112, 33, 45),
            width=int(3 * scale)
        )

    # To render evenodd fill:
    # 1. Create a mask layer for the outer polygon (subpaths[0])
    # 2. Draw subpaths[0] in white on mask
    # 3. Draw subpaths[1, 2, 3] in black on mask (the cutouts)
    # 4. Fill the masked area with FPT Orange Gradient
    mask = Image.new("L", (w, h), 0)
    m_draw = ImageDraw.Draw(mask)
    
    # Outer polygon
    m_draw.polygon(transformed_subpaths[0], fill=255)
    # The 3 internal cutout triangles
    for sp in transformed_subpaths[1:]:
        m_draw.polygon(sp, fill=0)
        
    # Create the gradient emblem layer
    emblem = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    e_draw = ImageDraw.Draw(emblem)
    
    # Generate linear vertical gradient from FPT Bright Orange (#FF8533) to FPT Primary (#F37021) to Warm (#E05A10)
    top_y = int(offset_y)
    bot_y = int(offset_y + target_h)
    
    for y in range(top_y, bot_y + 1):
        progress = max(0.0, min(1.0, (y - top_y) / (target_h if target_h > 0 else 1)))
        # Gradient colors:
        # 0.0 -> (255, 140, 50)
        # 0.5 -> (243, 112, 33) # Official FPT Orange
        # 1.0 -> (220, 85, 15)
        if progress < 0.5:
            t = progress / 0.5
            r = int(255 * (1 - t) + 243 * t)
            g = int(140 * (1 - t) + 112 * t)
            b = int(50 * (1 - t) + 33 * t)
        else:
            t = (progress - 0.5) / 0.5
            r = int(243 * (1 - t) + 220 * t)
            g = int(112 * (1 - t) + 85 * t)
            b = int(33 * (1 - t) + 15 * t)
            
        e_draw.line([(0, y), (w, y)], fill=(r, g, b, 255))
        
    # Apply mask
    emblem.putalpha(mask)
    
    # Add subtle drop shadow under the emblem
    shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow)
    shadow_offset = int(12 * scale)
    # Draw outer polygon in black shifted
    shifted_outer = [(p[0], p[1] + shadow_offset) for p in transformed_subpaths[0]]
    s_draw.polygon(shifted_outer, fill=(0, 0, 0, 160))
    for sp in transformed_subpaths[1:]:
        shifted_hole = [(p[0], p[1] + shadow_offset) for p in sp]
        s_draw.polygon(shifted_hole, fill=(0, 0, 0, 0)) # Don't fill holes
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=int(14 * scale)))
    
    img = Image.alpha_composite(img, shadow)
    img = Image.alpha_composite(img, emblem)
    
    # Also add the FPT Tri-Color accent touch (Blue & Green) on the cutouts or corners
    # Subpath 3 (top hole): subtle FPT Blue reflection
    # Subpath 1 (bottom hole): subtle FPT Green reflection
    accents = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    acc_draw = ImageDraw.Draw(accents)
    
    # Top cutout inner subtle stroke with FPT Blue #0054A6
    acc_draw.polygon(transformed_subpaths[3], outline=(0, 84, 166, 120), width=int(2 * scale))
    # Bottom cutout inner subtle stroke with FPT Green #008037
    acc_draw.polygon(transformed_subpaths[1], outline=(0, 128, 55, 120), width=int(2 * scale))
    
    img = Image.alpha_composite(img, accents)
    
    final_img = img.resize((size, size), Image.Resampling.LANCZOS)
    return final_img

if __name__ == '__main__':
    full_icon = render_official_polymarket_fpt(1024, is_foreground_only=False)
    full_icon.save('assets/icon/app_icon.png')
    print("Saved 1024x1024 master icon to assets/icon/app_icon.png")
    
    fg_icon = render_official_polymarket_fpt(1024, is_foreground_only=True)
    fg_icon.save('assets/icon/ic_launcher_foreground.png')
    print("Saved 1024x1024 adaptive foreground to assets/icon/ic_launcher_foreground.png")
