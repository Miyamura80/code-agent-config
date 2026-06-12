---
name: edison-brand
description: Edison.Watch Brand Design Guide
user_invocable: true
triggers:
  - /edison-brand
---

# Edison.Watch Brand Design Guide

Apply this brand guide whenever creating UI, graphics, documents, or any visual output for edison.watch.

---

## Base Color Palette (Usage Share)

| Name             | Hex       | Share |
|------------------|-----------|-------|
| Baseline Black   | `#000000` | 40%   |
| Graphene Grey    | `#9BA4A6` | 30%   |
| Core Cyan        | `#C3FFFD` | 20%   |
| Wavelength White | `#F9F9F9` | 10%   |

---

## Extended Color Palette

These are complementary accent colors - use sparingly as small touches, not as primary UI colors.

### Grid Grey

| Name           | Hex       |
|----------------|-----------|
| Grid Grey 50   | `#F9F9F9` |
| Grid Grey 100  | `#C8C8C8` |
| Grid Grey 200  | `#8F8F8F` |
| Grid Grey 300  | `#555555` |
| Grid Grey 400  | `#383838` |
| Grid Grey 500  | `#1C1C1C` |
| Grid Grey 600  | `#000000` |

### Core Cyan

| Name                  | Hex       |
|-----------------------|-----------|
| Core Cyan 400         | `#E0FFFE` |
| Core Cyan 500 (Main)  | `#C3FFFD` |
| Core Cyan 600         | `#7DE6E2` |

### Graphene Grey

| Name                       | Hex       |
|----------------------------|-----------|
| Graphene Grey 200          | `#A3A9B3` |
| Graphene Grey 500 (Main)   | `#5E6575` |
| Graphene Grey 800          | `#2F3440` |

### Circuit Green

| Name                       | Hex       |
|----------------------------|-----------|
| Circuit Green 400          | `#3EE7A0` |
| Circuit Green 500 (Main)   | `#00C781` |
| Circuit Green 600          | `#007A52` |

### Infra Red

| Name                    | Hex       |
|-------------------------|-----------|
| Infra Red 400           | `#FF6B7D` |
| Infra Red 500 (Main)    | `#FF3B4D` |
| Infra Red 600           | `#C3001A` |

---

## Brand Visual System: "The Hackbox"

**Core Aesthetic:** High-precision, utilitarian, modular visual identity inspired by HUD interfaces, cyber-minimalism, and blueprint UI design. Defined by strict monochromatic interaction between black background and electric cyan active elements.

### Color Rules

- **Background:** Void Black (`#000000`). All elements exist in infinite negative space.
- **Active Elements (Box & Tag):** Electric Cyan (`#C3FFFD`). Used for all structural wireframes and solid data blocks.
- **Typography:** Pure White (`#FFFFFF`). Maximum readability against the black background.

### Core Components

#### A. The Primary Box (The Container)

- **Shape:** Perfect 1:1 Square
- **Style:** Wireframe only. No fill.
- **Stroke Color:** `#C3FFFD` (Electric Cyan)
- **Stroke Weight:** Consistent, clean, thin-to-medium weight line

#### B. The Tag (The Modifier)

- **Shape:** Solid filled rectangle
- **Fill Color:** `#C3FFFD` (Electric Cyan)
- **Placement:** Superimposed over the perimeter/stroke of the Box. Never floating - must anchor to the wireframe edge.
- **The "40/10" Rule:**
  - Tag Width = **40%** of the Box's width
  - Tag Height = **10%** of the Box's height

### Variations & Logic

#### The Secondary Box (Horizontal)

Used when vertical space is constrained or for longer content (e.g., billboards).

- Take the Primary Box and apply:
  - **+30%** Width
  - **-30%** Height

#### Multiplicity (Layout)

- Scale by duplicating boxes rather than expanding a single box infinitely
- **Grid:** All elements align to a strict, invisible background grid
- **Rhythm:** When using multiple boxes, vary Tag placement (e.g., Top-Left on one, Bottom-Right on another) to create visual movement

### Typography & Grid

- **Font Style:** Archivo (Google Fonts). Neo-grotesque Sans-Serif. Text typically centered below the box cluster.
- **Grid Markers:** Occasional small, standalone cyan dashes (`#C3FFFD`) on background grid intersections to emphasize technical precision.

### Atmosphere Keywords

- Monochromatic Cybernetics
- Systemic
- Modular
- Computed Blueprint
- "Always On"

---

## Implementation Notes (Web / Tailwind CSS)

These are confirmed implementation details for the Hackbox component in web projects.

### Hackbox Border

- Use `border-2` (2px) — NOT `border` (1px). The brand requires a visible, clean wireframe stroke.

### Tag Positioning

- The tag sits **inside** the box at the corner, flush with the border edge.
- Use negative offsets matching the border width to cover the border at the corner:
  - `top-[-2px] left-[-2px]` for top-left
  - `top-[-2px] right-[-2px]` for top-right
  - `bottom-[-2px] left-[-2px]` for bottom-left
  - `bottom-[-2px] right-[-2px]` for bottom-right
- The tag must **never** float outside/above the box or straddle the border with `translate-y`. It anchors to the inner corner.

### Tag Sizing

- **Width:** `w-[40%]` of the box — applies to both primary and secondary variants.
- **Height (primary):** `h-[10%]` — percentage works because primary has `aspect-square`.
- **Height (secondary):** `h-7` (28px) — fixed height because secondary boxes have content-driven height.

### Content Clearance

- Content inside a Hackbox must have enough top padding to clear the tag area.
- Use `pt-12` (48px) minimum for secondary boxes to avoid tag/content overlap.
- Do **not** put text inside the Hackbox that duplicates the tag label (e.g., tag says "ABOUT", don't also have an "About me" heading as the Hackbox child — it's redundant).
