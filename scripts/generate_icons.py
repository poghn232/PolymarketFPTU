import os
import math
from PIL import Image, ImageDraw, ImageFilter

def create_polymarket_fpt_icon(size=1024, is_foreground_only=False):
    """
    Creates a high-resolution Polymarket-styled app icon with FPT signature colors.
    size: Target canvas size (e.g. 1024x1024)
    is_foreground_only: If True, renders with transparent background for Android adaptive icons.
    """
    scale = 2  # Super-sample 2x for ultra smooth antialiasing
    w = size * scale
    h = size * scale
    
    if is_foreground_only:
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    else:
        # Premium dark futuristic background matching Polymarket dark aesthetic
        img = Image.new("RGBA", (w, h), (11, 14, 23, 255))
        
        # Add subtle radial background gradient & soft glow
        bg_glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(bg_glow)
        
        cx, cy = w // 2, h // 2
        # Soft orange radial glow behind logo
        glow_radius = int(w * 0.42)
        glow_draw.ellipse(
            (cx - glow_radius, cy - glow_radius, cx + glow_radius, cy + glow_radius),
            fill=(243, 112, 33, 45)
        )
        bg_glow = bg_glow.filter(ImageFilter.GaussianBlur(radius=int(w * 0.12)))
        img = Image.alpha_composite(img, bg_glow)
        
        # Subtle rounded squircle container border if rendered as full icon
        draw_border = ImageDraw.Draw(img)
        border_radius = int(w * 0.22)
        # Draw sleek subtle squircle border
        border_box = (int(w * 0.04), int(h * 0.04), int(w * 0.96), int(h * 0.96))
        draw_border.rounded_rectangle(
            border_box,
            radius=border_radius,
            outline=(243, 112, 33, 60),
            width=int(4 * scale)
        )

    draw = ImageDraw.Draw(img)
    
    # Polymarket Logo Geometry:
    # An isometric geometric arrangement of 4 faceted rhombi (diamonds)
    # tilted at 30 degrees, separated by precise negative space gaps.
    # Dimensions calculated around center (cx, cy)
    cx, cy = w // 2, h // 2
    
    # Scale factor for the icon glyph
    # For adaptive foreground, icon should fit within 66% circle (Android design spec)
    glyph_scale = 0.58 if is_foreground_only else 0.68
    unit = (w * glyph_scale) / 2.6
    gap = unit * 0.08  # Gap between facets
    
    # Angle of isometric slant: 30 degrees
    rad30 = math.radians(30)
    cos30 = math.cos(rad30) # ~0.866
    sin30 = math.sin(rad30) # 0.5
    
    # Helper to calculate isometric point:
    # u axis along +30 deg (down-right), v axis along -30 deg (down-left)
    def iso_point(u, v, z=0):
        # u: top-left to bottom-right axis
        # v: top-right to bottom-left axis
        # z: vertical offset (positive = up)
        px = cx + (u - v) * cos30 * unit
        py = cy + (u + v) * sin30 * unit - z * unit
        return (px, py)
    
    # 4-Facet Polymarket Geometry:
    # Facet 1: Top Rhombus (Bright FPT Orange #FF7700 -> #F37021)
    # Facet 2: Left Rhombus (FPT Dark Blue #0054A6)
    # Facet 3: Right Rhombus (FPT Green #008037)
    # Facet 4: Bottom / Center-accent Rhombus (Deep Amber Orange #E65100)
    
    # Let's define the 4 rhombuses with rounded corners or crisp beveled facets:
    # 1. TOP RHOMBUS (Dominant FPT Orange)
    # 2. LEFT RHOMBUS (FPT Corporate Blue)
    # 3. RIGHT RHOMBUS (FPT Corporate Green)
    # 4. BOTTOM RHOMBUS (FPT Golden Warm Orange)
    
    # Let's define facet coordinates with gap:
    g = gap / (unit * 2)
    
    # Top Facet:
    p_top = [
        iso_point(0, -1 + g, 0.5),      # North
        iso_point(1 - g, 0, 0.5),       # East
        iso_point(0, 1 - g, 0.5),       # South
        iso_point(-1 + g, 0, 0.5),      # West
    ]
    
    # Left Facet (Lower left vertical / isometric wall)
    p_left = [
        iso_point(-1, 0 + g, 0.4),
        iso_point(0 - g, 1, 0.4),
        iso_point(0 - g, 1, -0.6),
        iso_point(-1, 0 + g, -0.6),
    ]
    
    # Right Facet (Lower right vertical / isometric wall)
    p_right = [
        iso_point(0 + g, 1, 0.4),
        iso_point(1, 0 + g, 0.4),
        iso_point(1, 0 + g, -0.6),
        iso_point(0 + g, 1, -0.6),
    ]
    
    # Bottom Facet / Base Floor (or front facing diamond)
    p_bottom = [
        iso_point(0, 1 + g, -0.6),
        iso_point(1 - g, 2, -0.6),
        iso_point(0, 3 - g, -0.6),
        iso_point(-1 + g, 2, -0.6),
    ]

    # Let's also create the iconic Polymarket 4-rhombus planar diamond projection:
    # Polymarket's actual logo consists of:
    # 4 flat isometric rhombi arranged in a 2x2 grid tilted at 30 deg:
    # Top-Left, Top-Right, Bottom-Left, Bottom-Right.
    # Let's compute their exact vertices so it matches Polymarket's recognizable geometry:
    rhombus_w = unit * 0.95
    rhombus_h = unit * 0.55
    r_gap_x = gap * 1.2
    r_gap_y = gap * 1.2
    
    # Center shift
    # Top-Left Rhombus:
    tl_center = (cx - rhombus_w * 0.5 - r_gap_x, cy - rhombus_h * 0.6 - r_gap_y)
    # Top-Right Rhombus:
    tr_center = (cx + rhombus_w * 0.5 + r_gap_x, cy - rhombus_h * 0.6 - r_gap_y)
    # Bottom-Left Rhombus:
    bl_center = (cx - rhombus_w * 0.5 - r_gap_x, cy + rhombus_h * 0.6 + r_gap_y)
    # Bottom-Right Rhombus:
    br_center = (cx + rhombus_w * 0.5 + r_gap_x, cy + rhombus_h * 0.6 + r_gap_y)

    def make_rhombus(center, w, h):
        c_x, c_y = center
        return [
            (c_x, c_y - h),      # Top
            (c_x + w, c_y),      # Right
            (c_x, c_y + h),      # Bottom
            (c_x - w, c_y)       # Left
        ]

    # Alternatively: Polymarket's 3D isometric faceted cube / origami hexagon:
    # Top Face (Rhombus): FPT Orange
    # Left Face: FPT Blue
    # Right Face: FPT Green
    # Inner Candy / Star core: Radiant Golden Yellow / White
    # This 3D isometric representation is universally beloved, distinctly Polymarket,
    # and showcases the 3 core FPT colors (Cam, Xanh dương, Xanh lá) in harmony!
    
    R = unit * 1.45 # Radius from center to vertices
    # 6 hexagon outer points: 30, 90, 150, 210, 270, 330 deg
    pts = []
    for i in range(6):
        angle = math.radians(30 + i * 60)
        pts.append((cx + R * math.cos(angle), cy + R * math.sin(angle)))
    # pts[0] = (30 deg: bottom right)
    # pts[1] = (90 deg: bottom center)
    # pts[2] = (150 deg: bottom left)
    # pts[3] = (210 deg: top left)
    # pts[4] = (270 deg: top center)
    # pts[5] = (330 deg: top right)
    
    # Gap vector calculations for clean sleek negative space cuts:
    gap_val = gap * 0.7
    
    # Top Face: between pts[4], pts[5], (cx, cy), pts[3]
    top_poly = [
        (cx, cy - gap_val * 1.4),
        (pts[5][0] - gap_val, pts[5][1] - gap_val * 0.5),
        (pts[4][0], pts[4][1] + gap_val * 0.8),
        (pts[3][0] + gap_val, pts[3][1] - gap_val * 0.5),
    ]
    
    # Left Face: between (cx, cy), pts[3], pts[2], pts[1]
    left_poly = [
        (cx - gap_val * 1.2, cy + gap_val * 0.5),
        (pts[3][0] + gap_val * 0.8, pts[3][1] + gap_val * 0.6),
        (pts[2][0] + gap_val * 0.8, pts[2][1] - gap_val * 0.5),
        (pts[1][0] - gap_val * 0.2, pts[1][1] - gap_val * 1.2),
    ]
    
    # Right Face: between (cx, cy), pts[5], pts[0], pts[1]
    right_poly = [
        (cx + gap_val * 1.2, cy + gap_val * 0.5),
        (pts[5][0] - gap_val * 0.8, pts[5][1] + gap_val * 0.6),
        (pts[0][0] - gap_val * 0.8, pts[0][1] - gap_val * 0.5),
        (pts[1][0] + gap_val * 0.2, pts[1][1] - gap_val * 1.2),
    ]

    # Draw Subtle Drop Shadows under the facets for depth
    shadow_offset = int(8 * scale)
    shadow_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_layer)
    for poly in [top_poly, left_poly, right_poly]:
        shifted_poly = [(p[0], p[1] + shadow_offset) for p in poly]
        s_draw.polygon(shifted_poly, fill=(0, 0, 0, 140))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=int(10 * scale)))
    img = Image.alpha_composite(img, shadow_layer)
    draw = ImageDraw.Draw(img)

    # 1. Top Face: Official FPT Orange Gradient (#FF8822 to #F37021)
    # Draw polygon with vivid gradient simulation
    draw.polygon(top_poly, fill=(243, 112, 33, 255))
    
    # Highlight on top face (beveled edge)
    top_highlight = [
        top_poly[2],
        top_poly[1],
        (top_poly[1][0] * 0.85 + top_poly[0][0] * 0.15, top_poly[1][1] * 0.85 + top_poly[0][1] * 0.15),
        (top_poly[2][0] * 0.7 + top_poly[3][0] * 0.3, top_poly[2][1] * 0.7 + top_poly[3][1] * 0.3),
    ]
    draw.polygon(top_highlight, fill=(255, 145, 60, 220))

    # 2. Left Face: Official FPT Blue (#0054A6)
    draw.polygon(left_poly, fill=(0, 84, 166, 255))
    # Beveled highlight on left face
    left_highlight = [
        left_poly[0],
        left_poly[1],
        (left_poly[1][0] * 0.8 + left_poly[2][0] * 0.2, left_poly[1][1] * 0.8 + left_poly[2][1] * 0.2),
        (left_poly[0][0] * 0.8 + left_poly[3][0] * 0.2, left_poly[0][0] * 0.8 + left_poly[3][0] * 0.2),
    ]
    draw.polygon(left_highlight, fill=(30, 120, 210, 180))

    # 3. Right Face: Official FPT Green (#008037)
    draw.polygon(right_poly, fill=(0, 128, 55, 255))
    # Beveled highlight on right face
    right_highlight = [
        right_poly[0],
        right_poly[1],
        (right_poly[1][0] * 0.8 + right_poly[2][0] * 0.2, right_poly[1][1] * 0.8 + right_poly[2][1] * 0.2),
        (right_poly[0][0] * 0.8 + right_poly[3][0] * 0.2, right_poly[0][0] * 0.8 + right_poly[3][0] * 0.2),
    ]
    draw.polygon(right_highlight, fill=(20, 165, 80, 180))

    # Center Emblem: Subtle Polymarket / FPT Diamond Inset or "P" incision
    # Adds a sleek futuristic look to the top facet
    inner_r = R * 0.32
    inner_top_poly = [
        (cx, cy - gap_val * 1.4 - inner_r * 0.5),
        (cx + inner_r * cos30, cy - gap_val * 1.4 - inner_r * 0.5 - inner_r * sin30),
        (cx, cy - gap_val * 1.4 - inner_r * 1.0),
        (cx - inner_r * cos30, cy - gap_val * 1.4 - inner_r * 0.5 - inner_r * sin30),
    ]
    draw.polygon(inner_top_poly, fill=(255, 255, 255, 220))

    # Downscale smoothly to requested size
    final_img = img.resize((size, size), Image.Resampling.LANCZOS)
    return final_img

if __name__ == '__main__':
    os.makedirs('assets/icon', exist_ok=True)
    icon = create_polymarket_fpt_icon(1024, is_foreground_only=False)
    icon.save('assets/icon/app_icon.png')
    print("Generated assets/icon/app_icon.png (1024x1024)")
