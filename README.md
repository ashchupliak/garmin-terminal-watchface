# Garmin Analog Watch Face

A minimalist analog watch face for Garmin Fenix 7 series devices.

## Features

- **Analog Time Display**: Classic analog hands showing hours, minutes, and seconds
- **Minute Markers**: Clear markers around the dial (thicker markers every 5 minutes)
- **Date Display**: Current day and date shown at the top
- **Digital Time**: Small digital time display at the bottom for quick reference
- **Steps Counter**: Daily step count with footprint icon on the left side
- **Red Second Hand**: Easy-to-see red second hand for precise time reading

## Design

The watch face features a clean, minimalist design with:
- White hour and minute hands
- Red second hand for contrast
- No hour numbers for a cleaner look
- Minute markers around the edge
- Black background for better battery life

## Compatibility

This watch face is designed for:
- Garmin Fenix 7
- Garmin Fenix 7S
- Garmin Fenix 7X

## Installation

1. Install the Garmin Connect IQ SDK
2. Clone this repository
3. Build the project using the Connect IQ SDK
4. Deploy to your device using Garmin Express or the Connect IQ app

## Building

```bash
# Build the project
monkeyc -d fenix7 -f monkey.jungle -o garminface.prg -y developer_key

# Deploy to simulator
monkeydo garminface.prg fenix7

# Deploy to device
# Use Garmin Express or Connect IQ mobile app
```

## Requirements

- Garmin Connect IQ SDK 3.2.0 or higher
- Compatible Garmin device (Fenix 7 series)

## Permissions

The watch face requires the following permissions:
- Background - For continuous updates
- Sensor - For heart rate monitoring (if implemented)
- SensorHistory - For historical sensor data
- UserProfile - For activity monitoring (steps)

## License

This project is licensed under the MIT License. 