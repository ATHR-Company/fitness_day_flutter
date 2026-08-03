#!/usr/bin/env python3
"""
Remove alpha channel from iOS app icons.
This script converts PNG icons with transparency to opaque PNG files with a white background.
"""

import os
from PIL import Image

def remove_alpha_channel(image_path, background_color=(255, 255, 255)):
    """
    Remove alpha channel from an image and replace with a solid background color.
    
    Args:
        image_path: Path to the PNG image
        background_color: RGB tuple for background (default: white)
    """
    try:
        # Open the image
        img = Image.open(image_path)
        
        # Check if image has alpha channel
        if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
            print(f"Processing: {os.path.basename(image_path)}")
            
            # Create a new image with white background
            if img.mode == 'P':
                img = img.convert('RGBA')
            
            background = Image.new('RGB', img.size, background_color)
            
            # Paste the image onto the background using alpha as mask
            if img.mode == 'RGBA':
                background.paste(img, mask=img.split()[3])  # Use alpha channel as mask
            else:
                background.paste(img)
            
            # Save the image
            background.save(image_path, 'PNG')
            print(f"✓ Removed alpha channel from {os.path.basename(image_path)}")
        else:
            print(f"⊘ {os.path.basename(image_path)} has no alpha channel")
            
    except Exception as e:
        print(f"✗ Error processing {image_path}: {e}")

def main():
    # Path to the app icon directory
    icon_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    
    if not os.path.exists(icon_dir):
        print(f"Error: Directory not found: {icon_dir}")
        return
    
    print("Removing alpha channels from iOS app icons...\n")
    
    # Process all PNG files in the directory
    for filename in os.listdir(icon_dir):
        if filename.endswith('.png'):
            file_path = os.path.join(icon_dir, filename)
            remove_alpha_channel(file_path)
    
    print("\n✓ Done! All icons processed.")
    print("\nNext steps:")
    print("1. Rebuild your iOS app: flutter clean && flutter build ios")
    print("2. Archive and upload to App Store Connect")

if __name__ == "__main__":
    main()
