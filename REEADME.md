So let's plan this thing out. Basically, simple, easy. It's a page, you launch it, and there'll be a description saying, you know, college fund for new baby, something like that. Then it can have a total, and then it can have a list of people and how much they've contributed, and then a button to contribute. Then the contribution options, we can integrate Stripe for ones with contributions, or I suppose subscriptions maybe, I'm not sure. And then, or you can say, I'll give cash, and then like enter the amount, or yeah, they can enter the amount and just send it directly via a regular bank transfer. Yeah, the interact transfer. So a person can basically select the payment method, either pay right now via Stripe, or just select another way, and just say how much they're going to be contributing. Then it adds that amount to the total and puts their name up on the list of contributors. And there should be a checkbox to say, contribute anonymously. So yeah, I think, yeah, that's pretty much it.I think I want to do Firebase, and I mean I don't even need to use a login, like the users don't even need to log in. Actually I don't even even if I know I don't even think I need to use Firebase. God my head hurts, no server ready, running a citizenship tracker. Can I not just host this there, you know, host there, yeah.

Use Flutter
## Firebase Implementation Plan
1. **Project Setup**
   - Create a Firebase project and enable Firebase Hosting, Firestore, and Cloud Functions.
   - Install Firebase CLI locally and initialize the project with Hosting (for the Flutter web build), Firestore, and Functions.
   - Configure environment variables/secrets for Stripe API keys using `firebase functions:secrets:set`.
2. **Data Model**
   - Define a `contributions` collection in Firestore with fields: `displayName`, `amount`, `currency`, `paymentMethod` (`stripe`, `interac`), `isAnonymous`, `status` (`pledged`, `paid`), and timestamps.
   - Optionally add a `settings` document to store the campaign description, goal amount, and total cached aggregate.
3. **Security Rules**
   - Write Firestore security rules allowing document creation with server-side validation via Cloud Functions while preventing direct arbitrary writes.
   - Enable App Check with reCAPTCHA to throttle automated submissions.
4. **Cloud Functions**
   - Implement an HTTPS callable/function to accept pledges: validate input, create Firestore documents, and trigger Stripe Checkout sessions for card payments.
   - Add a webhook function to receive Stripe events, marking contributions as `paid` when a session completes.
   - Provide an admin-only endpoint (protected via callable auth + secret) for reconciling Interac transfers.
5. **Flutter Web Frontend**
   - Build a single-page Flutter app that loads campaign metadata and contributions via Firestore streams.
   - Display the description, running total (sum of paid + pledged), contributor list (honoring `isAnonymous`), and a pledge form with payment method selection.
   - After form submission, call the Cloud Function; redirect to Stripe for card payments or show Interac instructions.
6. **Hosting & Deployment**
   - Configure Flutter build output (`build/web`) as the Firebase Hosting public directory.
   - Set up automatic deployments with `firebase deploy` (Hosting, Firestore rules, Functions) and enable preview channels for QA.
   - Add HTTP caching rules for static assets and use Firebase-managed SSL certificates.
7. **Monitoring & Analytics**
   - Enable Firebase Analytics or Google Analytics for event tracking (pledge started/completed).
   - Configure alerting for Cloud Function errors and Stripe webhook failures via Firebase Alerts or Google Cloud Monitoring.
8. **Future Enhancements**
   - Introduce optional authentication for admins, an export-to-CSV Cloud Function, and rate limiting for pledge submissions.
   - Consider integrating Firebase Extensions (e.g., "Run Subscription Payments with Stripe") if recurring contributions become necessary.
