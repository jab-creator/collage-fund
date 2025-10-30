# Firebase Firestore Integration Guide

This document provides detailed information about the Firebase Firestore integration implemented in the College Fund web application.

## Overview

The application uses Firebase Firestore as its primary database for storing campaign information and contribution data. The integration includes real-time synchronization, offline support, and graceful fallback to demo mode when Firebase is not configured.

## Architecture

### Data Models

#### Campaign Model (`lib/models/campaign.dart`)
```dart
class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  // Firestore serialization methods
  Map<String, dynamic> toFirestore();
  static Campaign fromFirestore(DocumentSnapshot doc);
}
```

#### Contribution Model (`lib/models/contribution.dart`)
```dart
class Contribution {
  final String id;
  final String campaignId;
  final String? contributorName;
  final double amount;
  final bool isAnonymous;
  final PaymentMethod paymentMethod;
  final ContributionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  // Firestore serialization methods
  Map<String, dynamic> toFirestore();
  static Contribution fromFirestore(DocumentSnapshot doc);
}

enum PaymentMethod { stripe, interac }
enum ContributionStatus { pending, completed, failed }
```

### Firestore Service (`lib/services/firestore_service.dart`)

The FirestoreService class provides all database operations:

#### Campaign Operations
- `getActiveCampaign()`: Retrieves the currently active campaign
- `createCampaign(Campaign)`: Creates a new campaign
- `updateCampaign(Campaign)`: Updates campaign information
- `watchCampaign(String)`: Real-time listener for campaign changes

#### Contribution Operations
- `createContribution(Contribution)`: Creates a new contribution
- `getContributionsForCampaign(String)`: Gets all contributions for a campaign
- `updateContributionStatus(String, ContributionStatus)`: Updates contribution status
- `watchContributions(String)`: Real-time listener for contribution changes

#### Development Utilities
- `initializeSampleData()`: Creates sample data for development and testing

## Real-time Updates

The application implements real-time updates using Firestore streams:

```dart
void _setupRealtimeListeners(String campaignId) {
  // Listen to campaign changes
  FirestoreService.watchCampaign(campaignId).listen((updatedCampaign) {
    setState(() {
      campaign = updatedCampaign;
    });
  });

  // Listen to contribution changes
  FirestoreService.watchContributions(campaignId).listen((updatedContributions) {
    setState(() {
      contributions = updatedContributions;
    });
  });
}
```

## Demo Mode Fallback

When Firebase is not properly configured, the application gracefully falls back to demo mode:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseConfigured = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirestoreService.initializeSampleData();
    firebaseConfigured = true;
  } catch (e) {
    print('Firebase not configured properly: $e');
    print('Running in demo mode with mock data');
  }
  
  runApp(CollegeFundApp(firebaseConfigured: firebaseConfigured));
}
```

## Firestore Database Structure

### Collections

#### `campaigns`
```
campaigns/
├── {campaignId}/
│   ├── title: string
│   ├── description: string
│   ├── goalAmount: number
│   ├── currentAmount: number
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── isActive: boolean
```

#### `contributions`
```
contributions/
├── {contributionId}/
│   ├── campaignId: string
│   ├── contributorName: string (nullable)
│   ├── amount: number
│   ├── isAnonymous: boolean
│   ├── paymentMethod: string ('stripe' | 'interac')
│   ├── status: string ('pending' | 'completed' | 'failed')
│   ├── createdAt: timestamp
│   └── completedAt: timestamp (nullable)
```

## Security Rules

Recommended Firestore security rules for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to campaigns
    match /campaigns/{campaignId} {
      allow read: if true;
      allow write: if request.auth != null; // Require authentication for writes
    }
    
    // Allow read access to contributions, write with validation
    match /contributions/{contributionId} {
      allow read: if true;
      allow create: if validateContribution();
      allow update: if request.auth != null;
    }
    
    function validateContribution() {
      return request.resource.data.keys().hasAll(['campaignId', 'amount', 'isAnonymous', 'paymentMethod', 'status', 'createdAt'])
        && request.resource.data.amount is number
        && request.resource.data.amount > 0
        && request.resource.data.paymentMethod in ['stripe', 'interac']
        && request.resource.data.status in ['pending', 'completed', 'failed'];
    }
  }
}
```

## Setup Instructions

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Enable Firestore Database
4. Choose "Start in test mode" for development

### 2. Configure Flutter App
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`
3. Configure FlutterFire: `flutterfire configure`
4. Select your project and platforms (Web)

### 3. Update Configuration
The `flutterfire configure` command will generate `lib/firebase_options.dart` with your project's configuration.

### 4. Initialize Sample Data
The app automatically initializes sample data when Firebase is properly configured. This includes:
- A sample campaign with goal of $10,000
- Several sample contributions with different payment methods
- Mix of anonymous and named contributors

## Error Handling

The integration includes comprehensive error handling:

- **Network Issues**: Firestore provides offline support with automatic sync
- **Configuration Errors**: Graceful fallback to demo mode
- **Permission Errors**: Clear error messages and fallback behavior
- **Data Validation**: Client-side validation before Firestore operations

## Performance Considerations

- **Real-time Listeners**: Automatically managed lifecycle to prevent memory leaks
- **Offline Support**: Firestore caching reduces network requests
- **Batch Operations**: Used for initializing sample data efficiently
- **Index Optimization**: Queries are designed to use automatic indexes

## Testing

### Development Testing
- Sample data is automatically created for testing
- Demo mode allows testing without Firebase configuration
- Real-time updates can be tested by opening multiple browser tabs

### Production Testing
- Use Firebase Emulator Suite for local testing
- Implement proper security rules before deployment
- Test offline functionality and sync behavior

## Next Steps

1. **Authentication**: Add Firebase Auth for admin functionality
2. **Cloud Functions**: Implement server-side payment processing
3. **Analytics**: Add Firebase Analytics for usage tracking
4. **Performance Monitoring**: Implement Firebase Performance Monitoring
5. **Push Notifications**: Add FCM for contribution notifications