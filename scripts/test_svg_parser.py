import re
import math
from PIL import Image, ImageDraw, ImageFilter

def parse_svg_path(path_str):
    """
    Simple SVG path parser for M, C, L, V, H, Z
    """
    commands = re.findall(r'([MCLVHZz])([^MCLVHZz]*)', path_str)
    subpaths = []
    current_subpath = []
    curr_x, curr_y = 0.0, 0.0
    start_x, start_y = 0.0, 0.0

    for cmd, args in commands:
        nums = [float(n) for n in re.findall(r'[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?', args)]
        if cmd == 'M':
            if current_subpath:
                subpaths.append(current_subpath)
                current_subpath = []
            curr_x, curr_y = nums[0], nums[1]
            start_x, start_y = curr_x, curr_y
            current_subpath.append((curr_x, curr_y))
        elif cmd == 'L':
            for i in range(0, len(nums), 2):
                curr_x, curr_y = nums[i], nums[i+1]
                current_subpath.append((curr_x, curr_y))
        elif cmd == 'V':
            for y in nums:
                curr_y = y
                current_subpath.append((curr_x, curr_y))
        elif cmd == 'H':
            for x in nums:
                curr_x = x
                current_subpath.append((curr_x, curr_y))
        elif cmd == 'C':
            # Cubic bezier: x1, y1, x2, y2, x, y
            for i in range(0, len(nums), 6):
                x1, y1, x2, y2, x, y = nums[i:i+6]
                # Approximate cubic bezier with 12 segments
                p0 = (curr_x, curr_y)
                p1 = (x1, y1)
                p2 = (x2, y2)
                p3 = (x, y)
                for step in range(1, 13):
                    t = step / 12.0
                    bx = (1-t)**3 * p0[0] + 3*(1-t)**2*t * p1[0] + 3*(1-t)*t**2 * p2[0] + t**3 * p3[0]
                    by = (1-t)**3 * p0[1] + 3*(1-t)**2*t * p1[1] + 3*(1-t)*t**2 * p2[1] + t**3 * p3[1]
                    current_subpath.append((bx, by))
                curr_x, curr_y = x, y
        elif cmd in ['Z', 'z']:
            current_subpath.append((start_x, start_y))
            subpaths.append(current_subpath)
            current_subpath = []
            curr_x, curr_y = start_x, start_y

    if current_subpath:
        subpaths.append(current_subpath)
    return subpaths

# Let's test with the Polymarket path
icon_d = "M136.267 152.495C136.267 159.76 136.267 163.392 133.891 165.192C131.516 166.993 128.019 166.012 121.024 164.049L8.63192 132.51C4.41793 131.328 2.31093 130.737 1.09248 129.129C-0.125977 127.522 -0.125977 125.333 -0.125977 120.957V47.0434C-0.125977 42.6667 -0.125977 40.4783 1.09248 38.8709C2.31093 37.2634 4.41792 36.6722 8.63191 35.4897L121.024 3.95096C128.019 1.98834 131.516 1.00703 133.891 2.80771C136.267 4.60839 136.267 8.24049 136.267 15.5047V152.495ZM27.9043 122.228L120.966 148.345V96.1133L27.9043 122.228ZM15.1738 110.111L108.217 84L15.1738 57.8887V110.111ZM27.9033 45.7725L120.966 71.8877V19.6553L27.9033 45.7725Z"

subpaths = parse_svg_path(icon_d)
print(f"Parsed {len(subpaths)} subpaths.")
for i, sp in enumerate(subpaths):
    print(f"Subpath {i}: {len(sp)} points, start: {sp[0]}, end: {sp[-1]}")
