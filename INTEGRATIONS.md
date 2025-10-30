# Firebase, Firestore, and Stripe Integration Guide

This project ships with a static Flutter web prototype. Follow the steps below to wire it to Firebase, Firestore, and Stripe for real data and payment processing.

## 1. Prerequisites

- Install the Firebase CLI: <https://firebase.google.com/docs/cli>
- Install the Flutter SDK (3.13+ recommended) and enable web support (`flutter config --enable-web`).
- Install the Stripe CLI for webhook testing: <https://stripe.com/docs/stripe-cli>
- Make sure you have Node.js 18+ (for Firebase Functions) and a Stripe account with API keys.

## 2. Firebase Project Setup

1. Create a new Firebase project (e.g., `baby-avery-fund`).
2. Enable the following products in the Firebase console:
   - **Hosting** (for the Flutter web build)
   - **Firestore** (in Native mode)
   - **Cloud Functions**
   - **App Check** (with reCAPTCHA v3)
3. In your local environment, sign in and initialize Firebase:

   ```bash
   firebase login
   firebase projects:create baby-avery-fund
   firebase use baby-avery-fund
   firebase init hosting firestore functions
   ```

   - When prompted for the hosting public directory, enter `build/web`.
   - Choose to configure as a single-page app.
   - Select TypeScript for Functions and install dependencies.

## 3. Firestore Data Model

Create a `contributions` collection with documents containing:

| Field           | Type     | Notes                                        |
|----------------|----------|----------------------------------------------|
| `displayName`   | string   | Display name or "Anonymous"                 |
| `amount`        | number   | Contribution amount in cents or dollars      |
| `currency`      | string   | e.g., `CAD`                                  |
| `paymentMethod` | string   | `stripe` or `interac`                        |
| `isAnonymous`   | boolean  | Whether to hide the donor's name             |
| `status`        | string   | `pledged` or `paid`                          |
| `createdAt`     | timestamp| Server timestamp                             |
| `checkoutUrl`   | string   | Optional Stripe Checkout session URL         |

Optionally add a `settings` document for campaign description, hero copy, and goal amount to avoid hardcoding content.

## 4. Security Rules

Deploy Firestore security rules that block direct writes and route everything through Cloud Functions:

```bash
firebase deploy --only firestore:rules
```

Sample rule snippet:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /contributions/{contributionId} {
      allow read: if true;
      allow create: if false; // Use callable/function writes only
      allow update, delete: if false;
    }
  }
}
```

Use App Check to mitigate automated spam submissions.

## 5. Cloud Functions + Stripe

1. In the `functions` directory initialize Stripe:

   ```bash
   npm install stripe firebase-admin firebase-functions cors
   ```

2. Store Stripe secrets in Firebase (never hardcode):

   ```bash
   firebase functions:secrets:set STRIPE_SECRET_KEY
   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
   ```

3. Implement an HTTPS callable function (`createContribution`) that:
   - Validates payload shape and amount limits.
   - Creates a Firestore document with status `pledged`.
   - For Stripe payments, calls `stripe.checkout.sessions.create` and returns the session URL.

4. Implement an HTTP endpoint (`stripeWebhook`) to receive Stripe events. On `checkout.session.completed` set the matching contribution status to `paid`.

5. Add an admin-only callable (`markInteracPaid`) that flips `pledged` contributions to `paid` after you verify the Interac transfer.

6. Emulate locally during development:

   ```bash
   firebase emulators:start --only functions,firestore,hosting
   # In another terminal
   stripe listen --forward-to localhost:5001/PROJECT_ID/REGION/stripeWebhook
   ```

## 6. Flutter Web Integration

1. Add Firebase packages to `pubspec.yaml`:

   ```yaml
   dependencies:
     cloud_firestore: ^5.5.0
     firebase_core: ^3.5.0
     firebase_app_check: ^0.2.1
   ```

2. Run `flutterfire configure` to generate `firebase_options.dart`.
3. Initialize Firebase in `main()` and replace the mock list with Firestore streams.
4. Update `_addContribution` to call the callable function and redirect to the returned Stripe Checkout URL when needed.

## 7. Deployment

1. Build the Flutter web app:

   ```bash
   flutter build web --release
   ```

2. Deploy Hosting, Firestore rules, and Functions:

   ```bash
   firebase deploy
   ```

3. Configure custom domain and SSL in Firebase Hosting if desired.

## 8. Monitoring

- Enable Crashlytics/Analytics for web if needed via Google Analytics.
- Configure Firebase Alerts for function errors and webhook delivery failures.
- In Stripe, configure email alerts for failed payouts or payment issues.

Following these steps will connect the Flutter prototype to production-ready infrastructure for collecting and tracking contributions.
