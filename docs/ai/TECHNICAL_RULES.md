# Orange Technical Rules

## Engine and Language

- Use Godot 4.x.
- Use GDScript only.
- Use 2D systems, not 3D gameplay.
- Target responsive web export.
- Use Compatibility renderer for web safety.
- Use nearest texture filtering for pixel-art clarity.

## Visual Direction

- Medium-detail cozy soft pixel art.
- Isometric view.
- Chibi isometric Orange.
- Pixel-art sprites with soft lighting/effects.
- Clean minimalist composition.
- Impactful vibrant oil-pastel-like pigment accents.
- Avoid color overload.
- Calm backgrounds, strong color accents.

## Controls

- Desktop: click to move, click objects, click contextual action button.
- Mobile/web touch: tap to move, tap objects, tap contextual action button.
- No keyboard-only gameplay.
- No virtual joystick unless explicitly requested later.

## UI

- Minimal cozy UI.
- One contextual action button.
- Mini picture frame for fragment progress.
- One-level hint button.
- Small bottom dialogue box for English translation.
- Floating minimal labels near objects.

## Sound

- Nature ambience plus gentle music.
- Music changes by episode feeling.
- Sound can support some puzzles, but every puzzle must remain solvable visually.

## Data

- JSON: dialogue, hints, floating labels, narrative content.
- Godot Resources: puzzle definitions, fragment rewards, key item definitions, scene/audio references.

## Save

- Save only on reward/state events, not every frame.
- Save after manual fragment collection.
- Save after key item completion.
- Load must restore current episode, current zone, completed puzzles, collected fragments, owned key items, completed key items, and flags.
