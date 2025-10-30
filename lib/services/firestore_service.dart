import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign.dart';
import '../models/contribution.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  static final CollectionReference _campaignsCollection = 
      _firestore.collection('campaigns');
  static final CollectionReference _contributionsCollection = 
      _firestore.collection('contributions');

  // Campaign operations
  static Future<Campaign?> getCampaign(String campaignId) async {
    try {
      DocumentSnapshot doc = await _campaignsCollection.doc(campaignId).get();
      if (doc.exists) {
        return Campaign.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting campaign: $e');
      return null;
    }
  }

  static Future<Campaign?> getActiveCampaign() async {
    try {
      QuerySnapshot query = await _campaignsCollection
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return Campaign.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting active campaign: $e');
      return null;
    }
  }

  static Future<String?> createCampaign(Campaign campaign) async {
    try {
      DocumentReference doc = await _campaignsCollection.add(campaign.toFirestore());
      return doc.id;
    } catch (e) {
      print('Error creating campaign: $e');
      return null;
    }
  }

  static Future<bool> updateCampaign(Campaign campaign) async {
    try {
      await _campaignsCollection.doc(campaign.id).update(campaign.toFirestore());
      return true;
    } catch (e) {
      print('Error updating campaign: $e');
      return false;
    }
  }

  static Stream<Campaign?> watchCampaign(String campaignId) {
    return _campaignsCollection.doc(campaignId).snapshots().map((doc) {
      if (doc.exists) {
        return Campaign.fromFirestore(doc);
      }
      return null;
    });
  }

  // Contribution operations
  static Future<String?> createContribution(Contribution contribution) async {
    try {
      DocumentReference doc = await _contributionsCollection.add(contribution.toFirestore());
      return doc.id;
    } catch (e) {
      print('Error creating contribution: $e');
      return null;
    }
  }

  static Future<bool> updateContribution(Contribution contribution) async {
    try {
      await _contributionsCollection.doc(contribution.id).update(contribution.toFirestore());
      return true;
    } catch (e) {
      print('Error updating contribution: $e');
      return false;
    }
  }

  static Future<List<Contribution>> getContributionsForCampaign(String campaignId) async {
    try {
      QuerySnapshot query = await _contributionsCollection
          .where('campaignId', isEqualTo: campaignId)
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs.map((doc) => Contribution.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting contributions: $e');
      return [];
    }
  }

  static Stream<List<Contribution>> watchContributionsForCampaign(String campaignId) {
    return _contributionsCollection
        .where('campaignId', isEqualTo: campaignId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contribution.fromFirestore(doc))
            .toList());
  }

  // Update campaign total when contribution is completed
  static Future<bool> completeContribution(String contributionId, String campaignId, double amount) async {
    try {
      // Use a transaction to ensure data consistency
      return await _firestore.runTransaction((transaction) async {
        // Get the current campaign
        DocumentSnapshot campaignDoc = await transaction.get(_campaignsCollection.doc(campaignId));
        if (!campaignDoc.exists) {
          throw Exception('Campaign not found');
        }

        Campaign campaign = Campaign.fromFirestore(campaignDoc);
        
        // Update contribution status
        transaction.update(_contributionsCollection.doc(contributionId), {
          'status': 'completed',
          'completedAt': Timestamp.now(),
        });

        // Update campaign total
        transaction.update(_campaignsCollection.doc(campaignId), {
          'currentAmount': campaign.currentAmount + amount,
          'updatedAt': Timestamp.now(),
        });

        return true;
      });
    } catch (e) {
      print('Error completing contribution: $e');
      return false;
    }
  }

  // Initialize with sample data (for development)
  static Future<void> initializeSampleData() async {
    try {
      // Check if we already have data
      QuerySnapshot existingCampaigns = await _campaignsCollection.limit(1).get();
      if (existingCampaigns.docs.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      // Create sample campaign
      Campaign sampleCampaign = Campaign(
        id: '',
        title: 'College Fund for New Baby',
        description: 'Help us save for our little one\'s future education. Every contribution, big or small, makes a difference in building a bright future for our child.',
        goalAmount: 10000.0,
        currentAmount: 2450.0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      String? campaignId = await createCampaign(sampleCampaign);
      if (campaignId == null) {
        print('Failed to create sample campaign');
        return;
      }

      // Create sample contributions
      List<Contribution> sampleContributions = [
        Contribution(
          id: '',
          campaignId: campaignId,
          contributorName: 'Sarah Johnson',
          amount: 500.0,
          isAnonymous: false,
          paymentMethod: PaymentMethod.stripe,
          status: ContributionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          completedAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        Contribution(
          id: '',
          campaignId: campaignId,
          contributorName: null,
          amount: 250.0,
          isAnonymous: true,
          paymentMethod: PaymentMethod.interac,
          status: ContributionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          completedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        Contribution(
          id: '',
          campaignId: campaignId,
          contributorName: 'Mike Chen',
          amount: 750.0,
          isAnonymous: false,
          paymentMethod: PaymentMethod.stripe,
          status: ContributionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          completedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Contribution(
          id: '',
          campaignId: campaignId,
          contributorName: 'Emily Davis',
          amount: 300.0,
          isAnonymous: false,
          paymentMethod: PaymentMethod.interac,
          status: ContributionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          completedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Contribution(
          id: '',
          campaignId: campaignId,
          contributorName: null,
          amount: 400.0,
          isAnonymous: true,
          paymentMethod: PaymentMethod.stripe,
          status: ContributionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Contribution(
          id: '',
          campaignId: campaignId,
          contributorName: 'David Wilson',
          amount: 250.0,
          isAnonymous: false,
          paymentMethod: PaymentMethod.interac,
          status: ContributionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      for (Contribution contribution in sampleContributions) {
        await createContribution(contribution);
      }

      print('Sample data initialized successfully');
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }
}