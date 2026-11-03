import urllib.request
import re

url = 'https://upload.wikimedia.org/wikipedia/commons/e/ec/Polymarket.svg'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as resp:
    content = resp.read().decode('utf-8')

matches = re.findall(r'<path([^>]+)>', content)
d_match = re.search(r'd="([^"]+)"', matches[1])
icon_d = d_match.group(1)
print(f"Icon Path length: {len(icon_d)}")
print(icon_d)
with open('scripts/polymarket_icon_path.txt', 'w') as f:
    f.write(icon_d)
