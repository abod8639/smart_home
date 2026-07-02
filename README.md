# Smart Home IoT

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/abod8639/smart_home/flutter_ci.yml?label=Build&style=for-the-badge&logo=github" alt="Build Status"/>
  <img src="https://codecov.io/gh/abod8639/smart_home/graph/badge.svg?token=TMDTYVIR8D" alt="Codecov"/>
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.12-02569B?style=for-the-badge&logo=flutter" alt="Flutter >= 3.12"/>
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.0-0175C2?style=for-the-badge&logo=dart" alt="Dart >= 3.0"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Desktop-success?style=for-the-badge" alt="Platforms"/>
  <img src="https://img.shields.io/badge/State-Riverpod-00D1B2?style=for-the-badge" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Backend-Firebase-FFCA28?style=for-the-badge&logo=firebase" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Protocol-Matter-6A0DAD?style=for-the-badge" alt="Matter"/>
  <img src="https://img.shields.io/badge/Transport-MQTT-660066?style=for-the-badge" alt="MQTT"/>
</p>

---

## Description

**Smart Home IoT** is a production-grade, cross-platform Flutter application for controlling and monitoring a custom ESP32-based smart home system. It provides real-time device management through a **dual-transport architecture**: MQTT over LAN is used as the primary, low-latency channel, with Firebase Realtime Database serving as an automatic cloud fallback whenever the local network is unavailable.

The app supports relay control, PWM dimming, infrared (IR) learning and playback, air-conditioning management, environmental sensor monitoring (temperature & humidity), and over-the-air (OTA) firmware updates. It also integrates with the **Matter** protocol (via the CHIP SDK) to onboard and control devices within the Google Home ecosystem. The UI adapts responsively across Android, iOS, and Linux desktop, and is built on **Clean Architecture** with **Riverpod** for predictable, testable state management.

---

## Key Features

| Feature | Details |
|---|---|
| **Relay Control** | Toggle individual GPIO-driven relays (lights, fans, etc.) |
| **PWM Dimming** | 8-bit (0–255) brightness control for dimmable loads |
| **AC Management** | Power on/off and target temperature control via IR |
| **AC Timer** | Scheduled AC shutdown with configurable delay (seconds) |
| **Sensor Monitoring** | Live temperature & humidity from ESP32 DHT sensors |
| **IR Learning** | Capture any remote control signal in 12–15 s |
| **IR Playback** | Replay saved IR codes (NEC, SAMSUNG, SONY, RAW) |
| **Room Management** | Organise devices by room with interactive floor plan |
| **Matter Commissioning** | BLE/Wi-Fi device onboarding via CHIP SDK |
| **Push Notifications** | Firebase Cloud Messaging alerts |
| **OTA Updates** | Trigger firmware updates from within the app |
| **Offline Resilience** | Automatic fallback from MQTT to Firebase RTDB |

---

## Architecture

The project follows **Clean Architecture** with a clear separation between UI, domain, and data layers. Feature modules are self-contained; shared infrastructure lives in `core/`.

```
┌─────────────────────────────┐
│        Presentation          │  Flutter Widgets + Riverpod providers
│  (features/ + core/widgets/) │
└──────────────┬──────────────┘
               │  watches / reads
┌──────────────▼──────────────┐
│         Domain Layer         │  Entities, Repository interfaces
│  (device/, room/, auth/ …)  │
└──────────────┬──────────────┘
               │  implements
┌──────────────▼──────────────┐
│          Data Layer          │  Services, Hive adapters, Firebase models
│       (core/services/)       │
└─────────────────────────────┘
```

### System Communication Diagram

```mermaid
flowchart TD
    UI["Flutter UI\n(Riverpod Widgets)"]

    subgraph Esp32Service["Esp32Service (core/services/)"]
        API["esp32_api.dart\n(Public API + Fallback Logic)"]
        MQTT_SVC["esp32_mqtt.dart\n(MQTT Connection)"]
        FB_SVC["esp32_firebase.dart\n(Firebase Sync)"]
        SYNC["esp32_controller_sync.dart\n(State → Riverpod)"]
    end

    subgraph Transport["Transport Layer"]
        MQTT["MQTT Broker\n(LAN · Port 1883)\nPrimary"]
        RTDB["Firebase RTDB\n(Cloud Fallback)"]
    end

    ESP32["ESP32 Firmware\n(esp32_smart_home_1)"]

    subgraph Hardware["Hardware"]
        Relay["Relays"] PWM["PWM Loads"] IR["IR Emitter Receiver"] AC["AC Unit"] Sensor["DHT Sensor"]
    end

    MatterSvc["MatterService\n(flutter_matter / CHIP SDK)"]
    GoogleHome["Google Home Ecosystem\n(Matter Fabric)"]

    UI --> API
    API --> MQTT_SVC
    API --> FB_SVC
    MQTT_SVC <-->|"cmd / state / event\n/ sensor / status"| MQTT
    FB_SVC <-->|"commands / pins\n/ ir_signal / status"| RTDB
    MQTT --> ESP32
    RTDB --> ESP32
    ESP32 --> Hardware
    SYNC --> UI

    UI --> MatterSvc
    MatterSvc <-->|"BLE / Wi-Fi\nCommissioning"| GoogleHome
```

---

## Communication Strategy

### Dual-Transport Routing

```
[User Action in UI]
        │
        ▼
[Esp32Service.sendCommand()]
        │
        ├─► [MQTT Connected?] ── Yes ─► [Send RAW Message over LAN] (sub-100ms)
        │
        └─► [MQTT Disconnected?] ── No ──► [Send via Firebase RTDB] (~1-3s)
```

### Connection Lifecycle

```
[App Startup]
      │
      ▼
[Load Broker URL from Hive]
      │
      ▼
[Connect to MQTT Broker]
      │
      ├─► Success ──► [Subscribe to Topics] ──► [Send get_state] ──► [Active MQTT Transport]
      │                                                                        │
      │                                                                   Connection
      │                                                                      Lost
      │                                                                        │
      └─► Failure/Disconnect ◄─────────────────────────────────────────────────┘
              │
              ▼
      [Route Commands to Firebase] ──► [Retry MQTT (5s delay)]
```

---

## MQTT Topics

All topics are prefixed with `smarthome/esp32_smart_home_1/`.

| Topic (suffix) | Direction | Retained | Description |
|---|---|:---:|---|
| `cmd` | App → ESP32 | ✗ | Outbound JSON commands |
| `state` | ESP32 → App | Yes | Full device state snapshot |
| `event` | ESP32 → App | ✗ | Delta events (`relay_update`, `pwm_update`, `ac_update`, `ir_learn_status`) |
| `sensor` | ESP32 → App | ✗ | Live sensor readings (temperature, humidity) |
| `status` | ESP32 → App | Yes | LWT — `online` / `offline` |

---

## Firebase RTDB Structure

```
(Firebase Realtime Database root)
│
├── devices/
│   └── esp32_smart_home_1/
│       ├── commands/          ← App writes JSON commands here (ESP32 polls every 3 s)
│       ├── pins/              → App reads relay & PWM states
│       ├── status             → App monitors online / offline
│       ├── ir_signal/         → App reads newly learned IR signals
│       ├── matter_payload/    → App reads QR code for Matter commissioning
│       ├── temperature        → Live DHT temperature reading
│       ├── humidity           → Live DHT humidity reading
│       └── target_temperature → Current AC setpoint
│
└── app_data/
    ├── rooms/                 ↔ Bidirectional sync (syncRooms)
    ├── devices/               ↔ Bidirectional sync (syncDevices)
    └── ir_codes/
        └── {deviceId}/
            └── {fieldKey}/    ↔ Saved IR button codes (IrCodeEntity)
```

> [!NOTE]
> The Firebase database URL is injected at runtime from the `.env` file and is never hardcoded. All Firebase access is authenticated via Firebase Auth.

---

## Core Services

### `Esp32Service` — Primary IoT Control

The central orchestrator for all hardware interactions. It is split across four part files for maintainability:

| File | Responsibility |
|---|---|
| `esp32_mqtt.dart` | MQTT client lifecycle, subscriptions, raw message handling |
| `esp32_api.dart` | Public API surface; selects MQTT or Firebase transport per call |
| `esp32_firebase.dart` | Firebase RTDB stream subscriptions and initialisation |
| `esp32_controller_sync.dart` | Translates incoming state payloads into Riverpod controller updates |

**Key behaviours:**
- Device ID: `esp32_smart_home_1`
- MQTT broker port: `1883` (configurable via Settings screen)
- Auto-reconnect: 5 s delay after disconnect
- On connect: subscribes to `state`, `sensor`, `event`, `status` and sends `get_state`

---

### `FirebaseService` — Cloud Data Layer

Manages all Firebase Realtime Database interactions:

- **Streams** (read): `pins`, `status`, `temperature`, `humidity`, `target_temperature`, `ir_signal`, `matter_payload`
- **Writes**: `sendCommand()` pushes a JSON payload to `devices/.../commands`; the ESP32 picks this up within 3 seconds
- **Sync**: `syncRooms()` and `syncDevices()` mirror local Hive data to `app_data/rooms` and `app_data/devices`

---

### `MatterService` — CHIP/Matter Protocol

Integrates the CHIP SDK via the `flutter_matter` package to support commissioning and control of Matter-certified devices:

| Method | Cluster | Description |
|---|---|---|
| `commissionDevice()` | — | BLE/Wi-Fi commissioning with completion listener |
| `toggleDevice()` | `0x0006` OnOff | Turn a Matter device on or off |
| `setBrightness()` | `0x0008` LevelControl | `MoveToLevel` command (0–254) |
| `setColor()` | `0x0300` ColorControl | `MoveToHueAndSaturation` command |

RGB → HSV conversion is handled internally before invoking the ColorControl cluster.

---

### `NotificationService` — Push Alerts

Initialises Firebase Cloud Messaging and registers handlers for:
- **Foreground** notifications (displayed in-app)
- **Background / terminated** notifications (system tray)

---

## Supported Commands

Commands are sent as JSON on the MQTT `cmd` topic or written to the Firebase `commands` node.

| `action` | Parameters | Description |
|---|---|---|
| `set_relay` | `pin` (int), `value` (0 \| 1) | Toggle a relay on or off |
| `set_pwm` | `pin` (int), `value` (0–255) | Set PWM duty cycle / brightness |
| `control_ac` | `isOn` (bool), `target_temp` (int) | Power and temperature control |
| `set_ac_timer` | `seconds` (int), `ir_code` (object) | Scheduled AC shutdown |
| `ir_send` | `protocol`, `value`, `bits`, `freq` | Transmit a stored IR code |
| `ir_learn` | _(none)_ | Begin IR signal capture (12 s MQTT / 15 s Firebase timeout) |
| `ota_start` | `url` (string) | Trigger OTA firmware download and flash |
| `add_device` | `type` (string), `pin` (int) | Register a new Matter endpoint |
| `get_state` | _(none)_ | Request a full device state snapshot |

**Example payload:**

```json
{
  "action": "set_relay",
  "pin": 4,
  "value": 1
}
```

---

## IR Control System

The IR system supports capture and playback of remote control signals for any consumer electronics device.

### Supported Protocols

| Protocol | Notes |
|---|---|
| `NEC` | Most common (TVs, set-top boxes) |
| `SAMSUNG` | Samsung TV/appliance remotes |
| `SONY` | Sony SIRC protocol |
| `RAW` / `UNKNOWN` | Full raw timing data for unsupported protocols |

### Learning Workflow

```
User               App (Esp32Service)        Transport             ESP32
  │                       │                      │                   │
  │─── 1. Press Learn ───►│                      │                   │
  │                       │─── 2. Send ir_learn ─┼──────────────────►│
  │                       │       command        │                   │
  │                       │                      │               (Capture)
  │                       │                      │                   │
  │                       │◄── 3. MQTT Event (ir_learn_status) ──────│ (Instant)
  │                       │                      or                  │
  │                       │◄── 4. Firebase Stream (ir_signal) ───────│ (Max 15s)
  │                       │                      │                   │
  │                       │─── 5. Save IrCodeEntity ────────────────►│ (Store in DB)
  ▼                       ▼                      ▼                   ▼
```

### IrCodeEntity

```dart
class IrCodeEntity {
  final String protocol;   // e.g., "NEC"
  final int    value;      // Hex value of the signal
  final int    bits;       // Signal bit length
  final int    frequency;  // Carrier frequency (Hz)
}
```

---

## Directory Structure

```
lib/
├── main.dart                          # Entry point · Firebase init · ProviderScope
├── firebase_options.dart              # Auto-generated Firebase config
│
├── core/
│   ├── bindings/                      # Riverpod initial bindings
│   ├── router/                        # App router (GoRouter / Navigator)
│   ├── routes/                        # Named route definitions
│   ├── services/
│   │   ├── esp32_service.dart         # Esp32Service entry point
│   │   ├── esp32/
│   │   │   ├── esp32_mqtt.dart        # MQTT connection & subscriptions
│   │   │   ├── esp32_api.dart         # Public API + MQTT/Firebase fallback
│   │   │   ├── esp32_firebase.dart    # Firebase stream init
│   │   │   └── esp32_controller_sync.dart  # State → Riverpod controllers
│   │   ├── firebase_service.dart      # Firebase RTDB service
│   │   ├── matter_service.dart        # Matter/CHIP commissioning & control
│   │   ├── hive_service.dart          # Hive local storage init
│   │   └── notification_service.dart  # Firebase Cloud Messaging
│   ├── theme/                         # Material 3 dark theme tokens
│   ├── utils/                         # Responsive breakpoint helpers
│   └── widgets/                       # Shared UI components
│
└── features/
    ├── auth/                          # Login screen · Firebase Auth flow
    ├── dashboard/                     # Main panel · device cards · weather widget
    ├── device/                        # Device entities · IR codes · device models
    ├── room/                          # Room management · floor plan · placement
    └── settings/                      # MQTT broker config · Matter pairing · prefs
```

---

## Technology Stack

| Category | Package | Purpose |
|---|---|---|
| **State Management** | `flutter_riverpod` + `riverpod_annotation` | Reactive state, dependency injection |
| **Hardware (Primary)** | `mqtt_client` | MQTT over LAN (port 1883) |
| **Hardware (Fallback)** | `firebase_database` | Firebase Realtime Database |
| **Matter Protocol** | `flutter_matter` | CHIP SDK device commissioning & control |
| **Local Storage** | `hive` + `hive_flutter` | Fast key-value persistence |
| **Authentication** | `firebase_auth` | Firebase user authentication |
| **Env Config** | `flutter_dotenv` | Runtime `.env` loading |
| **Unique IDs** | `uuid` | Generating device and room UUIDs |
| **Animations** | `lottie` | JSON-based Lottie animations |
| **Notifications** | `firebase_messaging` | Firebase Cloud Messaging (FCM) |

---

## Getting Started

### Prerequisites

- Flutter **≥ 3.12** ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK **≥ 3.0** (bundled with Flutter)
- A configured **Firebase project** with Realtime Database enabled
- An **MQTT broker** reachable on your LAN (e.g., [Mosquitto](https://mosquitto.org/))
- *(Optional)* An Android device/emulator with Google Play Services for Matter commissioning

### 1 — Clone the repository

```bash
git clone https://github.com/abod8639/smart_home.git
cd smart_home
```

### 2 — Configure environment variables

Create a `.env` file in the project root:

```env
FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com
```

> [!IMPORTANT]
> Never commit the `.env` file to version control. It is listed in `.gitignore` by default.

### 3 — Add Firebase config files

| Platform | File | Location |
|---|---|---|
| Android | `google-services.json` | `android/app/` |
| iOS | `GoogleService-Info.plist` | `ios/Runner/` |

Generate these from the [Firebase Console](https://console.firebase.google.com/) → Project Settings → Your Apps.

### 4 — Install dependencies

```bash
flutter pub get
```

If you use `riverpod_annotation`, run the code generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5 — Configure the MQTT broker

Launch the app, navigate to **Settings**, and enter your MQTT broker's local IP address. This is stored persistently via Hive.

### 6 — Run the app

```bash
# Android
flutter run -d android

# iOS (macOS required)
flutter run -d ios

# Linux Desktop
flutter run -d linux
```

---

## ESP32 Firmware

The companion ESP32 firmware that this app communicates with is maintained in a separate repository:

> **[smart_home_IoT_idf](https://github.com/abod8639/smart_home_IoT_idf)** — ESP-IDF firmware with MQTT, Firebase, IR control, AC management, and Matter support.

The firmware implements:
- MQTT client connecting to the same broker as the app
- Firebase RTDB polling for cloud-relayed commands (every 3 s)
- DHT sensor readings published to `sensor` topic
- Relay and PWM GPIO control
- IR learning and transmission (NEC, SAMSUNG, SONY, RAW)
- Last Will and Testament (LWT) on the `status` topic
- Matter/CHIP SDK endpoint registration

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made using Flutter, MQTT, Firebase, and Matter
</p>
