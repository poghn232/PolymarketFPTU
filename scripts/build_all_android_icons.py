import os
import sys
from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render_polymarket_fpt import render_official_polymarket_fpt

def generate_all_icons():
    # 1. Generate master high-res icons (1024x1024)
    print("Generating 1024x1024 master icons...")
    master_icon = render_official_polymarket_fpt(1024, is_foreground_only=False)
    master_fg = render_official_polymarket_fpt(1024, is_foreground_only=True)
    
    os.makedirs('assets/icon', exist_ok=True)
    master_icon.save('assets/icon/app_icon.png', 'PNG')
    master_fg.save('assets/icon/ic_launcher_foreground.png', 'PNG')

    # Create round master icon by masking master_icon with circle
    round_mask = Image.new("L", (1024, 1024), 0)
    r_draw = ImageDraw.Draw(round_mask)
    r_draw.ellipse((8, 8, 1016, 1016), fill=255)
    master_round = master_icon.copy()
    master_round.putalpha(round_mask)
    master_round.save('assets/icon/app_icon_round.png', 'PNG')

    # Standard Android mipmap densities and dimensions
    # ic_launcher & ic_launcher_round: 48dp
    standard_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    # Adaptive icon foreground: 108dp
    adaptive_fg_sizes = {
        'mipmap-mdpi': 108,
        'mipmap-hdpi': 162,
        'mipmap-xhdpi': 216,
        'mipmap-xxhdpi': 324,
        'mipmap-xxxhdpi': 432,
    }

    res_dir = 'android/app/src/main/res'
    
    for density, size in standard_sizes.items():
        density_dir = os.path.join(res_dir, density)
        os.makedirs(density_dir, exist_ok=True)

        # 1. ic_launcher.png
        icon_path = os.path.join(density_dir, 'ic_launcher.png')
        resized = master_icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(icon_path, 'PNG')

        # 2. ic_launcher_round.png
        round_path = os.path.join(density_dir, 'ic_launcher_round.png')
        resized_round = master_round.resize((size, size), Image.Resampling.LANCZOS)
        resized_round.save(round_path, 'PNG')

        # 3. ic_launcher_foreground.png
        fg_size = adaptive_fg_sizes[density]
        fg_path = os.path.join(density_dir, 'ic_launcher_foreground.png')
        resized_fg = master_fg.resize((fg_size, fg_size), Image.Resampling.LANCZOS)
        resized_fg.save(fg_path, 'PNG')

        print(f"Generated {density}: ic_launcher ({size}x{size}), round ({size}x{size}), foreground ({fg_size}x{fg_size})")

    # 4. Generate values/colors.xml for adaptive icon background
    values_dir = os.path.join(res_dir, 'values')
    os.makedirs(values_dir, exist_ok=True)
    colors_xml_path = os.path.join(values_dir, 'colors.xml')
    with open(colors_xml_path, 'w', encoding='utf-8') as f:
        f.write('''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0F172A</color>
</resources>
''')
    print("Created values/colors.xml")

    # 5. Generate mipmap-anydpi-v26 for Android 8.0+ adaptive icons
    v26_dir = os.path.join(res_dir, 'mipmap-anydpi-v26')
    os.makedirs(v26_dir, exist_ok=True)

    with open(os.path.join(v26_dir, 'ic_launcher.xml'), 'w', encoding='utf-8') as f:
        f.write('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''')

    with open(os.path.join(v26_dir, 'ic_launcher_round.xml'), 'w', encoding='utf-8') as f:
        f.write('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''')
    print("Created mipmap-anydpi-v26/ic_launcher.xml and ic_launcher_round.xml")

if __name__ == '__main__':
    generate_all_icons()
    print("ALL ANDROID APP ICONS GENERATED SUCCESSFULLY!")
