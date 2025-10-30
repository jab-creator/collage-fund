# College Fund Web Application

A Flutter web application for crowdfunding college education expenses. This app allows family and friends to contribute to a college fund with support for multiple payment methods, anonymous contributions, and real-time updates via Firebase Firestore.

## Features

### ✅ Implemented
- **Campaign Display**: Shows campaign title, description, and funding progress
- **Progress Tracking**: Visual progress bar with current amount and goal
- **Contributor List**: Displays all contributors with support for anonymous donations
- **Contribution Form**: Easy-to-use form with:
  - Name input (optional for anonymous contributions)
  - Amount input with validation
  - Anonymous contribution checkbox
  - Payment method selection (Stripe/Interac)
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Firebase Integration**: Complete Firestore setup with data models and services
- **Real-time Updates**: Live updates when contributions are added
- **Demo Mode**: Graceful fallback when Firebase is not configured

### 🚧 In Progress
- **Stripe Payment Processing**: Secure credit card payments
- **Interac Transfer Support**: Canadian e-transfer handling

## Current Status

**Firebase Firestore Integration Complete!** 

The app now includes:
- Complete Firebase Firestore integration with real-time data synchronization
- Campaign and Contribution data models with proper serialization
- FirestoreService with CRUD operations and real-time listeners
- Graceful fallback to demo mode when Firebase is not configured
- Sample data initialization for development and testing

### Demo Mode
When Firebase is not properly configured, the app runs in demo mode showing:
- $2,450 raised of $10,000 goal (24.5% progress)
- 6 sample contributors including anonymous ones
- Functional contribution form with demo payment instructions

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Web browser for testing
- Firebase project (optional - app works in demo mode without it)

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

### Firebase Setup (Optional)
To enable real-time data persistence:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Firestore Database
3. Install Firebase CLI: `npm install -g firebase-tools`
4. Configure Firebase for your project:
   ```bash
   firebase login
   flutterfire configure
   ```
5. Update `lib/firebase_options.dart` with your project configuration

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
├── main.dart                    # Main application with UI components
├── models/
│   ├── campaign.dart           # Campaign data model with Firestore integration
│   └── contribution.dart       # Contribution data model with payment methods
├── services/
│   └── firestore_service.dart  # Firebase Firestore service with CRUD operations
├── firebase_options.dart       # Firebase configuration (auto-generated)
└── widgets/                    # Reusable UI components (planned)
```

## Firebase Integration Details

### Data Models
- **Campaign**: Stores campaign information (title, description, goal, current amount)
- **Contribution**: Tracks individual contributions with payment method and status
- **Real-time Listeners**: Automatic UI updates when data changes

### Firestore Collections
- `campaigns`: Campaign documents with metadata
- `contributions`: Contribution documents linked to campaigns

### Key Features
- Automatic sample data initialization for development
- Real-time synchronization across multiple clients
- Offline support with Firestore caching
- Graceful error handling and fallback to demo mode

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
