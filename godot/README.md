# Skibidi Toilet Defense — Godot vertical slice

This folder is an independent Godot 4 port of the existing browser game. The
original website files remain at the repository root and are not required by
the Godot build. The slice uses procedural drawing, so it has no external
runtime, analytics, or asset dependencies.

## Run

1. Install Godot 4.x from <https://godotengine.org/download/>.
2. Import this directory (`godot/`) in the Godot Project Manager.
3. Press **F6** or **F5** and choose `Main.tscn` if prompted.

## Controls

- Left click/tap a toilet: fire the sewer cannon (damage and collect energy).
- **T**: arm an electro-plunger trap, then click the sewer floor (10 energy).
- **H**: summon Titan Drillman (25 energy); it auto-attacks nearby toilets.
- **P**: pause/resume. **R** restarts after the gate is overrun.

Toilets advance from the right edge toward the alliance gate. Clear each wave
before the gate HP reaches zero; later waves add tougher, varied enemies.

## Export notes

Use **Project > Export** and install the matching Godot export templates.
For Windows, add a Windows Desktop preset and export an `.exe`. For Android,
enable the Android build template, configure an OpenJDK/Android SDK path, and
export an APK/AAB. For iOS, export from macOS with the iOS template and finish
signing/provisioning in Xcode. Touch input is supported alongside mouse input.
