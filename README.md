# SPM Monitoring System

An IoT-based power meter monitoring system for real-time energy management across a fleet of Raspberry Pi devices, each reading multiple kWh meters via Modbus RS485.

## Overview

- **Fleet**: ~20 Raspberry Pi devices deployed across multiple locations
- **Scale**: Up to 180 kWh meters per Pi (largest deployment)
- **Protocol**: Modbus RTU over RS485
- **Stack**: Laravel (PHP) + Node-RED + SQLite

Built with AI-assisted development using Claude (Anthropic) for architecture decisions, code generation, debugging, and iterative feature development.

## Supported Power Meters

| Model | Protocol | Register Map |
|-------|----------|-------------|
| Schneider PM5350 | Modbus RTU | Float32, base 2999 |
| Schneider PM5560 | Modbus RTU | Float32, base 2999 |
| Schneider PM5500 | Modbus RTU | Float32, base 2999 |
| Schneider PM810MG | Modbus RTU | INT16 + scale factors |
| ABB M2M Basic | Modbus RTU | Float32, base 12288 |
| Schneider SPM91 | Modbus RTU | INT16 |
| Schneider SPM93 | Modbus RTU | INT16 |

## Features

- **Real-time dashboard** — live voltage, current, power, frequency, power factor per device
- **Energy tracking** — kWh, kVArh, kVAh with tariff breakdown (WBP/LWBP)
- **Fleet management** — centralized monitoring of all Pi devices from one interface
- **Device setup** — add/edit/remove meters via web UI (single or batch)
- **Auto-recovery** — SQLite index repair on corruption, Node-RED FSM watchdog
- **Dark SCADA theme** — navy + orange UI optimized for control room displays
- **Export** — monthly energy reports to Excel

## Architecture

```
[kWh Meters] --RS485--> [Raspberry Pi + Node-RED] --SQLite--> [Laravel Dashboard]
                                                                       |
                                                              [Web Browser / Display]
```

Each Pi runs:
- **Node-RED**: Modbus polling engine, device state machine, SQLite writer
- **Laravel**: REST API + web dashboard (port 8000)
- **SQLite**: Local time-series storage for readings

## AI-Assisted Development

This project was developed with heavy use of AI tools:

- **Claude (Anthropic)** via Claude Code CLI — primary development assistant
- Used for: architecture design, Modbus register mapping, Laravel/PHP code, Node-RED function nodes, debugging FSM issues, fleet deployment automation
- **Workflow**: Human orchestrator (project owner) + AI agent (implementation) — all code reviewed and tested on physical hardware

### Example AI-assisted tasks:
- Reverse-engineering Modbus register maps from meter datasheets
- Debugging RS485 bus contention issues
- Writing SQLite corruption recovery scripts
- Automating deployment across 20 Pi devices via SSH

## Tech Stack

- **Backend**: Laravel 11 (PHP 8.2)
- **IoT Engine**: Node-RED 3.x
- **Database**: SQLite (per-device local storage)
- **Hardware**: Raspberry Pi 4 / Pi 3B+
- **Communication**: RS485 USB adapters (FTDI/CH340)
- **Frontend**: Blade templates + Tailwind CSS + Font Awesome (offline)

## Hardware Setup

```
Raspberry Pi
├── /dev/ttyUSB0  → RS485 bus 1 (up to 32 devices)
├── /dev/ttyUSB1  → RS485 bus 2
└── /dev/ttyUSB2  → RS485 bus 3

RS485 Wiring:
  Pi USB-RS485 adapter A(+) → Meter terminal A
  Pi USB-RS485 adapter B(-) → Meter terminal B
  Termination: 120Ω at bus endpoints
```

## Installation

```bash
# Clone
git clone https://github.com/budisubejo/spm-monitoring.git
cd spm-monitoring

# Install PHP dependencies
composer install --no-dev

# Setup environment
cp .env.example .env
php artisan key:generate

# Initialize database
php artisan migrate

# Start server
php artisan serve --host=0.0.0.0 --port=8000
```

Node-RED flows are imported via the Node-RED UI (`flows/data-collector.json`).

## API Endpoints (Node-RED)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/devices` | List all configured devices |
| POST | `/api/devices` | Add new device |
| PUT | `/api/devices/:id` | Update device |
| DELETE | `/api/devices/:id` | Remove device |
| GET | `/api/readings/latest` | Latest readings for all devices |
| POST | `/api/reload-devices` | Reload device config from DB |

## License

MIT
