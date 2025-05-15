# Game Design Document: Open Source Clone of Superpower 2

## Project Principles

### 1. Cloning (in a Good Way)

The initial goal of this project is to recreate the core mechanics of the original Superpower 2 game. While we do not aim to replicate the exact methods used in the original, we strive to capture its essence. Over time, we may:
- Remove unnecessary elements.
- Introduce new features to address gaps.
- Refine mechanics based on community input.

These deviations will only occur after the initial goal of recreating the core mechanics has been achieved.

### 2. Open Source

This project is intended as a half-educational effort, leveraging the potential of the original game. It is entirely non-profit, and no financial gain is expected. To respect the developers of the original Superpower 2, the following guidelines are essential:
- The game must remain open source.
- Any attempt to make the game closed source or commercial is strictly prohibited, as it could upset the original developers.
- The project is a tribute to the original developers, showing respect and gratitude for their work.

### 3. Performance

Optimization is a core priority. The game should be capable of handling numerous intensive processes, including but not limited to:
- Economic calculations.
- Artificial intelligence (AI) routines.
- Geopolitical simulations.

This focus ensures that the game remains efficient and scalable, allowing modders to expand functionality without compromising performance.

### 4. Functions Above Graphics

High-quality graphics are not a primary objective. Our visual goals are limited to achieving parity with the original game's graphical fidelity. Any improvements in graphics will only be considered after the initial gameplay and functional goals are met.

### 5. Modding Community

The game is designed to be:
- **Optimized**: Capable of handling additional features and extensions.
- **Modular and Flexible**: Offering core functionality that serves as a foundation for modders to build upon.
    

The project encourages a vibrant modding community by:
- Supporting modular design.
- Allowing additional layers of functionality to be added via mods.
- Empowering users to customize the game to their preferences.
    

---

## OpenPower Structure

```
├── addons                 # Plugins used to enhance the engine.
│   ├── godot-sqlite       # SQLite database integration.
│   ├── json_editor        # JSON data editing tools.
│   ├── loggie             # Enhanced logging functionality.
├── assets                 # Multimedia assets used in the game.
│   ├── godot_engine_logo  # Logos for branding or placeholders.
│   ├── logo               # Game-specific logos.
│   ├── music              # Background music tracks.
│   ├── textures           # Textures for 3D models or UI.
│   └── video              # Video cutscenes or tutorials.
├── data                   # Game data files, configurations, or save data.
├── docs                   # Documentation for developers.
├── game                   # Core game logic and structure.
│   ├── editor             # Custom editor scripts and tools.
│   ├── lib                # Libraries and autoload scripts.
│   │   └── db_manager.gd  # Database manager
│   └── world              # Game world-related code.
│       ├── server         # Server-side game logic.
│       │   ├── world.gd   # World logic
│       │   ├── country.gd # Country class
│       │   └── region.gd  # Region class
├── loc                    # Localization files for multiple languages.
├── _archive               # Deprecated or archived files for reference.
└── _utils                 # Utility scripts or tools for development.
