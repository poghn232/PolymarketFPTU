path = 'android/app/src/main/AndroidManifest.xml'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

target = 'android:label="polymarket_fpt"'
replacement = 'android:label="FPT Market"\r\n        android:roundIcon="@mipmap/ic_launcher_round"'

if target in content:
    content = content.replace(target, replacement)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated AndroidManifest.xml successfully!")
else:
    print("Target not found!")
