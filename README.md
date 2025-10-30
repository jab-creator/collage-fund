# College Fund Web Application

A Flutter web application for crowdfunding college education expenses. This app allows family and friends to contribute to a college fund with support for multiple payment methods and anonymous contributions.

## Features

- **Campaign Display**: Shows campaign title, description, and funding progress
- **Progress Tracking**: Visual progress bar with current amount and goal
- **Contributor List**: Displays all contributors with support for anonymous donations
- **Contribution Form**: Easy-to-use form with:
  - Name input (optional for anonymous contributions)
  - Amount input with validation
  - Anonymous contribution checkbox
  - Payment method selection (Stripe/Interac)
- **Responsive Design**: Works seamlessly on desktop and mobile devices

## Current Status

This is the first version with a complete UI and sample data. The app currently shows:
- $2,450 raised of $10,000 goal (24.5% progress)
- 6 sample contributors including anonymous ones
- Functional contribution form (payment processing to be implemented)

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Web browser for testing

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run -d chrome
   ```

### Building for Web
```bash
flutter build web
```

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions including:
- Firebase Hosting
- Netlify
- Vercel
- GitHub Pages

## Planned Features

- **Firebase Integration**: Real-time data storage and updates
- **Stripe Payment Processing**: Secure credit card payments
- **Interac Transfer Support**: Canadian e-transfer handling
- **Admin Panel**: Campaign management interface
- **Email Notifications**: Contribution confirmations
- **Social Sharing**: Easy sharing of campaign links

## Project Structure

```
lib/
├── main.dart          # Main application with UI components
├── models/            # Data models (planned)
├── services/          # Payment and database services (planned)
└── widgets/           # Reusable UI components (planned)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
