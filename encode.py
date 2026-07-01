import base64, os
os.makedirs('lib/core/constants', exist_ok=True)
b64 = base64.b64encode(open('assets/audio/claps.mp3', 'rb').read()).decode('utf-8')
open('lib/core/constants/claps_audio.dart', 'w').write(f'const String clapsBase64 = "{b64}";')
