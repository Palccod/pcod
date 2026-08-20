# Bloub Avatar for Omarchy Quattro

An animated SVG avatar (bloub) plugin for Omarchy Quattro featuring morphing shapes, theme-synced colors, draggable positioning, and customizable expressions.

![Preview](preview.png)

## Features

- **Animated Morphing Avatar**: SVG-based animation with smooth shape morphing between 8 cloud-like forms
- **Shape Customization**: 8 built-in shapes (Cloud, Circle, Pebble, Squircle, Capsule, Triangle, Hexagon, Droplet)
- **Color Modes**: Default (Ink), Theme Accent (synced with Omarchy theme), or Custom Color
- **Rest Expressions**: 7 expressions (Idle, Thinking, Sleep, Wink, Wide Eyes, Alert, Happy)
- **Draggable Positioning**: Unlock and drag anywhere on screen, with mouse wheel resize
- **Workspace Awareness**: Show on all workspaces or a specific one
- **Keyboard Navigation**: Arrow keys to move, P to lock/unlock, T to test, Esc to close
- **Bar Widget**: Clickable bar icon with tooltip and context menu

## Installation

```bash
omarchy plugin add https://github.com/palccod/omarchy-bloub-avatar.git --enable
```

## Update

```bash
omarchy plugin update palccod.bloub-avatar --yes && omarchy restart shell
```

## Removal

```bash
omarchy plugin remove palccod.bloub-avatar
```

## Controls

### Bar Widget
- **Left-click**: Open settings panel
- **Right-click**: Toggle avatar active/inactive
- **Middle-click**: Play test animation (wink)
- **Ctrl + Scroll**: Resize avatar
- **Hover**: Tooltip with current status

### Settings Panel
- **P**: Lock/Unlock position
- **T**: Test animation (wink)
- **Arrow Keys**: Move avatar by 10px (when unlocked)
- **Esc**: Close panel

### Drag Mode (when unlocked)
- **Left-click + Drag**: Reposition avatar
- **Scroll Wheel**: Resize avatar
- **Right-click**: Lock position
- **Panel Controls**: X/Y position spinners, Center/Reset/Lock buttons

## Configuration

All settings are managed through the Omarchy bar settings UI (right-click bar → Configure Bar → Bloub Avatar) or the plugin's settings panel.

### Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Active | Boolean | true | Show/hide the avatar |
| Lock Position | Boolean | true | Prevent accidental dragging |
| X Position | Integer | -1 (auto) | Horizontal position (-1 = centered) |
| Y Position | Integer | -1 (auto) | Vertical position (-1 = centered) |
| Avatar Width | Integer | 200 | Size in pixels (60-640) |
| Shape | Enum | nuage | Cloud, Circle, Pebble, Squircle, Capsule, Triangle, Hexagon, Droplet |
| Color Mode | Enum | theme | Default, Theme Accent, Custom |
| Custom Color | String | #3b93f0 | Hex color when mode is Custom |
| Expression | Enum | idle | Idle, Thinking, Sleep, Wink, Wide, Alert, Happy |
| Animation Speed | Float | 1.0 | Speed multiplier (0.25x - 3.0x) |
| Workspace | Integer | 0 (all) | 0 = all workspaces, 1-10 = specific |

## Shape Preview

| Shape | ID | Description |
|-------|-----|-------------|
| ☁ Cloud | `nuage` | Default - soft cloud-like blob |
| ⭘ Circle | `cercle` | Perfect circle |
| 🪨 Pebble | `galet` | Organic rounded stone |
| ⬢ Squircle | `squircle` | Rounded square |
| 💊 Capsule | `capsule` | Pill/stadium shape |
| 🔺 Triangle | `triangle` | Rounded triangle |
| ⬡ Hexagon | `hexagone` | Rounded hexagon |
| 💧 Droplet | `goutte` | Teardrop shape |

## Color Modes

1. **Default**: Pure ink black (`#0a0a0c`) - classic bloub look
2. **Theme**: Uses Omarchy's current accent color - automatically updates with theme changes
3. **Custom**: Any `#RRGGBB` hex color

## Credits

- **bloub Animation System**: Based on [jeremy-prt/bloub](https://github.com/jeremy-prt/bloub) - SVG recreation of the x.ai bot avatar with 14-state morphing
- **Bongo Cat Plugin Structure**: Reference implementation from [HANCORE-linux/omarchy-bongocat](https://github.com/HANCORE-linux/omarchy-bongocat)
- **Omarchy Quattro**: Shell framework by [basecamp/omarchy](https://github.com/basecamp/omarchy)

## License

MIT License - see [LICENSE](LICENSE) for details.

The bloub animation design imitates the x.ai/Grok bot avatar visual behavior. "Grok" and "x.ai" are trademarks of their respective owners. This plugin is not affiliated with, endorsed by, or connected to x.ai.