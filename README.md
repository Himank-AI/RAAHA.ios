# RAAHA – SwiftUI prototype (frontend only)

Open `Raaha.xcodeproj` in **Xcode 16 or later** (Xcode 26 recommended for Liquid Glass), pick an iPhone simulator, press Run.

* iOS 17+ · SwiftUI · no backend, no network · all content is in `Raaha/Models/MockData.swift`
* Font: system font (SF Pro) via Dynamic Type text styles. Palette: `Raaha/Theme/Theme.swift`
* The project uses a synchronized folder, so new files you add under `Raaha/` are picked up automatically.

## Flow
Home → Plan Journey → Route Options → (Fastest / Cheapest / Most Comfortable / Safest) → Start Journey →
live legs (tap the "Next Transfer" card to advance; "Missed my train!" on the Train leg) → Destination Reached.
Explore → Plan Ahead → Check → Trip Preview → Save Trip → Trip Saved.

## Placeholders to replace with your Figma originals
Photos and the Home illustration were cropped from your PNG exports (low resolution). Drop the original
files into `Raaha/Assets.xcassets` using the same image-set names. The auto-rickshaw glyph (`icon_auto`) is
a simple vector placeholder.
