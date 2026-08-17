# harbour-popquizza

Native Sailfish OS client for [Popquizza](https://popquizza.com) — ten new
pop music questions every day.

Questions are fetched from popquizza.com; everything else (scores, streaks,
history) lives on the device. A port of the Gleam/Lustre web app to
QML/Silica.

## Building

Requires the [Sailfish SDK](https://sailfishos.org/wiki/Application_SDK).
From the SDK workspace:

```
sfdk -c target=SailfishOS-5.1.0.11-aarch64 build
```

## License

AGPL-3.0-or-later, same as the web app.
