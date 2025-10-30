# College Fund Web App (Flutter)

This Flutter web prototype implements the single-page experience described in `REEADME.md`. It showcases:

- Campaign overview with hero copy and running totals (paid vs pledged)
- Contribution list honoring anonymous donors
- Contribution form with amount validation, payment method selection, anonymity toggle, and pledge vs paid toggle
- Snack bar feedback indicating next steps for Stripe or Interac contributions

The data is held in-memory for demonstration; connect Firebase/Stripe using [`INTEGRATIONS.md`](INTEGRATIONS.md).

## Prerequisites

- Flutter SDK 3.13 or higher with web support enabled (`flutter config --enable-web`).

## Local Development

```bash
flutter pub get
flutter run -d chrome
```

This launches the single-page web experience at `http://localhost:xxxx`.

## Build for Production

```bash
flutter build web --release
```

The output is generated in `build/web`, ready for Firebase Hosting as outlined in the integration guide.
