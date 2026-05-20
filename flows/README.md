# SPM Monitoring — Node-RED Modbus Engine

This directory contains Node-RED flow configurations for the SPM Monitoring data collection engine.

## Flow: Data Collector

Polls power meters via Modbus RTU and writes readings to SQLite.

### Supported Device Types

- `PM5350` / `PM5560` / `PM5500` — Schneider Electric PM5000 series
  - Float32 Big Endian, base address 2999
  - Serial number at register 129
  - Energy at register 3203 (INT64, 36 registers)

- `PM810MG` — Schneider Electric PM800 series
  - INT16 with scale factors (registers 3209–3214)
  - Energy at register 1700 (MOD10 format)

- `ABB_M2M` — ABB M2M Basic
  - Float32 Big Endian, base address 12288 (0x3000)
  - Energy at register 12416 (0x3080)

- `SPM93` / `SPM91` — Schneider SPM series
  - INT16, base address 0

### Register Maps

#### Schneider PM5350/PM5560/PM5500 (Float32, base 2999)
| Offset | Register | Parameter | Unit |
|--------|----------|-----------|------|
| 0-1 | 2999 | (padding) | - |
| 10-11 | 3009 | 3-Phase Current | A |
| 20-21 | 3019 | Voltage L1-L2 | V |
| 22-23 | 3021 | Voltage L2-L3 | V |
| 24-25 | 3023 | Voltage L3-L1 | V |
| 28-29 | 3027 | Voltage L1-N | V |
| 30-31 | 3029 | Voltage L2-N | V |
| 32-33 | 3031 | Voltage L3-N | V |
| 60-61 | 3059 | 3-Phase Active Power | kW |
| 68-69 | 3067 | 3-Phase Reactive Power | kVAr |
| 76-77 | 3075 | 3-Phase Apparent Power | kVA |
| 84-85 | 3083 | Power Factor | - |
| 110-111 | 3109 | Frequency | Hz |

Energy (INT64, base 3203):
| Offset | Register | Parameter |
|--------|----------|-----------|
| 0-3 | 3203 | Active Energy Delivered (Wh) |
| 16-19 | 3219 | Reactive Energy Delivered (VARh) |
| 32-35 | 3235 | Apparent Energy Delivered (VAh) |

#### ABB M2M Basic (Float32, base 12288 / 0x3000)
| Offset | Register | Parameter | Unit |
|--------|----------|-----------|------|
| 0-1 | 12288 | Voltage L1-N | V |
| 2-3 | 12290 | Voltage L2-N | V |
| 4-5 | 12292 | Voltage L3-N | V |
| 6-7 | 12294 | Voltage L1-L2 | V |
| 8-9 | 12296 | Voltage L2-L3 | V |
| 10-11 | 12298 | Voltage L3-L1 | V |
| 24-25 | 12312 | 3-Phase Current | A |
| 34-35 | 12322 | 3-Phase Active Power | W |
| 42-43 | 12330 | 3-Phase Reactive Power | VAr |
| 50-51 | 12338 | 3-Phase Apparent Power | VA |
| 58-59 | 12346 | Power Factor | - |
| 60-61 | 12348 | Frequency | Hz |
| 62-63 | 12350 | Active Energy Import | kWh |
| 64-65 | 12352 | Reactive Energy Import | kVArh |

Total Energy (base 12416):
| Register | Parameter |
|----------|-----------|
| 12416 | Total Active Energy | kWh |
| 12418 | Total Reactive Energy | kVArh |

## Deployment

1. Import `flows.json` via Node-RED UI (http://pi-ip:1880)
2. Ensure SQLite database exists at configured path
3. Add devices via SPM Monitoring web UI or direct DB insert
4. Node-RED auto-starts polling on deploy
