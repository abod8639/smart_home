# Smart Home IoT

A professional Flutter application for real-time monitoring and control of a smart home network. The app acts as a unified control panel that bridges a mobile/desktop interface to physical IoT hardware, supporting two distinct communication protocols: a custom ESP32 HTTP API and the open Matter standard via Google Home integration.

---

## Purpose

The application is designed for homeowners and developers who have built or are building a DIY smart home using ESP32 microcontrollers as the central hub. It solves the problem of fragmented device management by providing a single, visually rich interface to:

- Control all smart devices (lamps, air conditioners, RGB strips, door locks, robot vacuums) from one place.
- Program and replay infrared remote signals for any AC unit or IR-compatible device, eliminating the need for physical remotes.
- Visualize the physical layout of all devices on a room floor plan.
- Monitor real-time environmental data (temperature, humidity, airflow, power usage) polled from the ESP32 hub.
- Add new certified Matter devices directly through the Google Home commissioning flow.

---

## How It Works

### Hardware Communication Layer

The app communicates with an ESP32 microcontroller hub running a local HTTP server on the same Wi-Fi network. The IP address of the hub is configured once in the Settings screen and stored persistently using SharedPreferences.

All hardware commands are dispatched through `Esp32Service`, a GetX service that wraps the Dio HTTP client. The service exposes the following operations:

- **Digital Output** (`/control/digital`): Toggles GPIO relay channels for lamps and door locks.
- **Analog / PWM Output** (`/control/analog`): Writes PWM duty cycle values (0-255) for dimming lamps or controlling RGB strips.
- **IR Learn** (`/control/ir/learn`): Puts the ESP32 IR receiver into learning mode for up to 12 seconds, captures the incoming signal, and returns a structured IR code object.
- **IR Send** (`/control/ir/send`): Transmits a previously learned IR code through the ESP32 IR LED transmitter.
- **Sensor Data** (`/sensors`): Reads live environmental metrics from the hub.
- **Ping** (`/ping`): Checks hub reachability before any critical operation.

### Matter Protocol Integration

For devices certified under the Matter standard (Thread, Wi-Fi, or BLE commissioning), the app integrates with Google Home's CHIP Device Controller via the `flutter_matter` library. The `MatterService` handles:

- **Commissioning**: Pairs a new Matter device using a setup PIN code and registers it on the local fabric.
- **OnOff Cluster** (Cluster 0x0006): Toggles device power.
- **LevelControl Cluster** (Cluster 0x0008): Sets brightness via the `MoveToLevel` command.
- **ColorControl Cluster** (Cluster 0x0300): Sets RGB color by converting the input RGB values to HSV and sending a `MoveToHueAndSaturation` command.

### IR Remote Control System

The IR control system is one of the most advanced features in the application. For AC units and other IR-controlled devices, the user can record signals directly from their physical remote by pointing it at the ESP32 IR receiver. Each button (Power, Temp Up, Temp Down, Auto, Cool, Heat, Eco) is stored as a separate JSON-encoded `IrCodeEntity` in the device record.

The system supports the following IR protocols: NEC, Samsung, Sony, LG, Panasonic, Denon, Sharp, JVC, RC5, RC6, PulseDistance, PulseWidth, and RAW formats. Stored codes are validated via a round-trip integrity check before being saved to disk.

When the temperature is adjusted on the dashboard, the app automatically sends the Temp Up or Temp Down signal the required number of times in rapid succession (220 ms intervals) to match the target delta.

A global mutex (`_irBusy`) ensures only one IR HTTP request is in flight at a time, preventing signal collisions on the ESP32.

### Data Persistence

All device state and room configuration is stored locally on the device using Hive, a fast key-value NoSQL database. On first launch, the app seeds a set of mock devices. On subsequent launches, the persisted state is loaded directly from Hive, preserving all user modifications including IR codes, device positions, brightness levels, and room assignments.

### Live Weather Integration

The dashboard displays live weather data fetched from two external APIs:

1. **ipapi.co**: Determines the user's city, country, latitude, and longitude based on IP geolocation.
2. **Open-Meteo**: A free, open-source weather API that returns current temperature and a WMO weather condition code.

The app maps WMO codes to human-readable conditions and generates a contextual smart home suggestion based on the current temperature and weather pattern.

### Room Floor Plan

The Room Placement screen displays a room background image with interactive draggable markers representing each device. Markers are positioned using normalized coordinates (0.0 to 1.0) relative to the image dimensions, making them resolution-independent. Users can long-press and drag any marker to reassign a device's position. The full device property panel is accessible from this screen, including IR recording controls.

---

## Architecture

The project follows Flutter Clean Architecture principles with strict separation of concerns across three layers per feature:

```
lib/
  core/
    bindings/       # GetX dependency injection (InitialBinding)
    routes/         # Named route definitions
    services/       # Esp32Service, MatterService, HiveService
    theme/          # AppTheme (dark palette, typography)
    utils/          # Responsive breakpoints utility
    widgets/        # Shared UI components (GlassContainer)
  features/
    dashboard/      # Main shell, navigation, weather widget, device cards
    device/         # DeviceEntity, IrCodeEntity, device card widgets
    room/           # Room management, floor plan placement, IR controls
    settings/       # Hub config, Google Home, preferences, profile
```

**State Management**: GetX is used throughout for reactive state, dependency injection, and navigation. Controllers are injected at the appropriate scope using `InitialBinding` for global services and route-level `BindingsBuilder` for scoped controllers.

**Responsiveness**: A `Responsive` utility class defines three breakpoints (mobile: < 600px, tablet: < 1100px, desktop: >= 1100px). All layout widgets query this utility to adapt padding, spacing, font sizes, and column arrangements at runtime.

---

## Technology Stack

| Category | Technology |
|---|---|
| Framework | Flutter (Dart SDK >= 3.12) |
| State Management | GetX 4.7 |
| Hardware Communication | Dio 5.9 (HTTP client for ESP32 REST API) |
| Matter Protocol | flutter_matter (custom local library wrapping CHIP SDK) |
| Local Storage | Hive 2.2 + Hive Flutter |
| User Preferences | SharedPreferences 2.5 |
| Geolocation | ipapi.co (IP-based, no permission required) |
| Weather Data | Open-Meteo API (open-source, no API key) |
| IR Protocol | IRremote (on ESP32 firmware side) |
| Image Picker | image_picker 1.1 (room photo selection) |
| Equality Checks | Equatable 2.0 (immutable entity comparisons) |
| Animations | Lottie 3.3 |
| Real-time Streaming | web_socket_channel 3.0 |
| Design System | Material 3 dark theme, Glassmorphism (BackdropFilter) |
| Architecture Pattern | Clean Architecture + Repository Pattern |

---

## Hardware Requirements

The application is designed to work with an ESP32 microcontroller flashed with firmware that exposes the following HTTP endpoints on the local network:

| Endpoint | Method | Description |
|---|---|---|
| `/ping` | GET | Hub reachability check |
| `/sensors` | GET | Environmental sensor readings |
| `/control/digital` | POST | GPIO relay on/off control |
| `/control/analog` | POST | PWM output (0-255) |
| `/control/ir/learn` | GET | Start IR signal recording |
| `/control/ir/send` | POST | Transmit a stored IR code |
| `/control/ac` | POST | Raw AC command (fallback) |

The hub IP address is configurable from the Settings screen without requiring an app restart.

---

## Getting Started

1. Flash your ESP32 with compatible firmware that exposes the REST API endpoints listed above.
2. Ensure the ESP32 and the device running this app are on the same local Wi-Fi network.
3. Clone the repository and run:

```bash
flutter pub get
flutter run
```

4. Open Settings in the app, enter the ESP32 IP address, and verify the hub connection status indicator turns green.
5. Use the Room Placement screen to assign physical positions to your devices on the floor plan.
6. For AC units, open the device settings panel and record IR signals for each control button using the physical remote.
