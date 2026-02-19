# SteamOS Boot Mode Buttons v2 Specification

## Goals

- Evolve the widget from a two-button launcher into a robust, configurable Plasma 6 applet.
- Provide explicit user feedback for command execution and failures.
- Add initial customization controls without breaking current defaults.

## Non-goals (for v2 Phase 1)

- Advanced SteamOS introspection APIs.
- Full dynamic profile management (create/delete arbitrary named profiles).
- Full icon-only compact representation.

## Current baseline (v1)

- Two fixed buttons execute:
  - `steamos-session-select plasma-x11-persistent`
  - `steamos-session-select gamescope`
- No busy state, no visible success/error feedback, no settings.

## v2 architecture

### UI surface

- Main applet view with optional title and description text.
- Mode action buttons arranged horizontally or vertically.
- Status row showing:
  - idle / running / success / error state
  - concise message text
  - optional detailed error text

### Command execution

- Keep using Plasma executable data engine (`Plasma5Support.DataSource`).
- Introduce one active command at a time (prevent command overlap).
- Parse command output keys defensively (`stdout`, `stderr`, `exit code` variants).

### Configuration model

Persisted fields:

- `showHeading` (bool, default `true`)
- `showDescription` (bool, default `true`)
- `desktopButtonText` (string, default `Set Desktop Boot`)
- `gameButtonText` (string, default `Set Game Boot`)
- `confirmBeforeApply` (bool, default `false`)
- `layoutMode` (enum int: `0` horizontal, `1` vertical; default `0`)

### Interaction model

- Clicking a button triggers command if not already running.
- If `confirmBeforeApply` is enabled, show inline confirmation before execution.
- Running state disables both buttons.
- Success/failure message appears after command completion.

## Phased roadmap

## Phase 1 (implemented in this change)

- Add `V2_SPEC.md`.
- Add configuration schema + config UI.
- Add status state handling and result message rendering.
- Add running-state button disablement.
- Add customizable labels and basic layout mode.

## Phase 2

- ✅ Expanded config page with notification controls (global enable + per-result toggles).
- ✅ Wired passive notification behavior to success/error command outcomes.
- Read actual current default boot target at load/refresh.
- Add refresh action and optional auto-refresh interval.
- Add more robust command-availability check and guided remediation text.

## Phase 3

- ✅ Panel/desktop adaptive behavior with panel-focused compact labels and orientation-aware button arrangement.
- ✅ Optional notifications and reboot action are implemented with configurable confirmation.
- ✅ Localization-ready UI strings and improved accessibility names/descriptions for controls and status text.

## Acceptance criteria for Phase 1

- User can change labels and layout via widget settings.
- User sees running/success/error status directly in widget.
- Widget prevents duplicate concurrent command launches.
- Default behavior remains equivalent to v1 without settings changes.


## Phase 4

- ✅ Advanced options: preset profiles, custom command overrides, command availability check, and optional reboot action with confirmation.
