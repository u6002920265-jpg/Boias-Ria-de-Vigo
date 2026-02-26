# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS SwiftUI app (iOS 17+) for tracking maritime buoys in the Ría de Vigo, Galicia, Spain. Users view buoys on an interactive map, filter by shipping route, and add new buoys using nautical DDM coordinate format.

## Build & Test Commands

```bash
# Build for simulator
xcodebuild -scheme "Boias Ria de Vigo" -destination "platform=iOS Simulator,name=iPhone 16" build

# Run tests
xcodebuild test -scheme "Boias Ria de Vigo" -destination "platform=iOS Simulator,name=iPhone 16"

# Run a single test class
xcodebuild test -scheme "Boias Ria de Vigo" -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:"Boias Ria de VigoTests/Boias_Ria_de_VigoTests"
```

## Architecture

**Pattern:** MVVM using Swift 5.10 `@Observable` (not `ObservableObject`). Views use `@Bindable` to bind to the view model.

**Data flow:**
- `BuoysViewModel` is the single source of truth for all app state (buoys array, active route, selected buoy, map camera position, map style)
- Views receive the view model and call methods or mutate `@Bindable` properties directly
- No persistence layer — buoys are in-memory only (loaded via `loadInitialBuoys()` at startup)

**Key files:**
- `ViewModels/BuoysViewModel.swift` — central state; `visibleBuoys` and `routeCoordinates` are computed from `activeRoute`
- `Models/Buoy.swift` — `BuoySide` enum: `.babor` (port/red) and `.estribor` (starboard/green)
- `Models/Route.swift` — `RouteId` enum with 4 numbered routes + `.all`; each route defines an ordered `buoyNames` array used to filter and draw polylines
- `Utilities/CoordinateFormatter.swift` — converts decimal degrees ↔ DDM (DD° MM.MMM') format; longitude uses `O` (Oeste) not `W`
- `Views/BuoyMapView.swift` — `Map` with `Annotation` markers and `MapPolyline` for active route; `BuoyMarker` color: orange=selected, blue=all-routes view, red=babor, green=estribor

## Known Incomplete State

The project has scaffolding that has not been wired together:

1. **App entry point is wrong:** `Boias_Ria_de_VigoApp.swift` launches `ContentView`, which is the unmodified Xcode CoreData boilerplate template. The actual app views (`BuoyMapView`, `BuoyListView`, `RouteSelectorView`, etc.) exist in `Views/` but are not connected to the entry point.

2. **Missing type:** `MapStyleOption` is referenced in `BuoysViewModel` (`var mapStyle: MapStyleOption`) and `MapStylePicker.swift` but is not defined anywhere. It needs to be a `CaseIterable`, `Identifiable`, `RawRepresentable<String>` enum with a `.standard` case and a `.mapStyle` property returning `MapStyle`.

3. **`BuoysViewModel` is truncated:** The file ends mid-function inside `fitMapToVisibleBuoys`. The `loadInitialBuoys()` method body is also missing.

4. **Dead files:** `Item.swift`, `Persistence.swift`, and `ContentView.swift` are Xcode template remnants. `Config.swift` is an environment variable injection template that does nothing at runtime.

## Coordinate Format

Input/display uses DDM: `42° 13.500' N` / `08° 43.560' O`. `CoordinateFormatter` handles formatting; `AddBuoyView` splits input into degrees + decimal minutes + direction picker. Internally stored as decimal degrees (`Double`).
