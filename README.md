# twotimesusage

A simple iOS app and widget that tells you whether Claude is currently offering **2x usage** on your Anthropic subscription.

Claude Pro and Team plans get double the usage allowance outside peak hours (weekdays 12:00-18:00 UTC) and on weekends. This app tracks that in real time so you always know the best time to use Claude.

## Features

- **Usage status** — shows whether 2x usage or peak hours are active based on the current time
- **Countdown timer** — tells you exactly when the next status change happens
- **Home screen widgets** — small and medium sizes with a rainbow gradient during 2x periods
- **Lock screen widgets** — circular, rectangular, and inline variants
- **Custom Claude mascot** — a pixel-art Claude character drawn entirely with SwiftUI Canvas paths

## Screenshots

<p align="centre">
  <img src="assets/screenshots/widget-home.png" width="250" alt="Home screen widget showing 2x usage with rainbow gradient" />
  <img src="assets/screenshots/main-2x.png" width="250" alt="Home screen widget during peak hours" />
  <img src="assets/screenshots/widget-lockscreen.png" width="250" alt="Lock screen widgets" />
</p>

## Demo

https://github.com/user-attachments/assets/4d7bcf3e-1ee2-4cf1-9026-c23360504eea

## How It Works

The app determines usage status based on the current time in UTC:

| Period | Status |
|---|---|
| Weekdays 12:00-18:00 UTC | Peak Hours (normal usage) |
| Weekdays outside 12:00-18:00 UTC | 2x Usage |
| Weekends (all day) | 2x Usage |

Peak hours are also displayed in your local timezone within the app.

> **Note:** Due to iOS widget limitations, the widget may not update instantly. Press the refresh button on the widget to get the latest status.

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Building

1. Clone the repository
2. Open `twotimesusage.xcodeproj` in Xcode
3. Update the `DEVELOPMENT_TEAM` in build settings to your own Apple Developer Team ID
4. Build and run on your device

## Licence

This project is open source. Feel free to use it however you like.
