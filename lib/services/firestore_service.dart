import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/app_state.dart';

enum RecTag {
  personalised,
  itemCF,
  popular
}

class RecommendedAttraction {
  final Attraction attraction;
  final double score;
  final RecTag tag;

  const RecommendedAttraction(
    this.attraction,
    this.score,
    this.tag,
  );
}

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  //==================================================
  // Fetch Attractions
  //==================================================
  Future<List<Attraction>> fetchAttractions() async {
    final snap =
        await _db.collection('attractions').get();

    return snap.docs
        .map(
          (d) => Attraction.fromFirestore(
            d.id,
            d.data(),
          ),
        )
        .toList();
  }

  //==================================================
  // User Preferences
  //==================================================
  Future<Map<String,dynamic>>
      _fetchUserPrefs() async {

    if (_uid == null) return {};

    final doc =
        await _db
            .collection('users')
            .doc(_uid)
            .get();

    return doc.data() ?? {};
  }

  //==================================================
  // Activity Log
  //==================================================
  Future<List<Map<String,dynamic>>>
      _fetchActivityLog() async {

    if (_uid == null) return [];

    final snap = await _db
        .collection('activity_log')
        .where(
          'user_id',
          isEqualTo: _uid,
        )
        .get();

    return snap.docs
        .map((d)=>d.data())
        .toList();
  }

  //==================================================
  // Collaborative Trips Data
  //==================================================
  Future<List<Map<String,dynamic>>>
      _fetchAllTrips() async {

    final snap =
        await _db.collection('trips').get();

    return snap.docs
        .map((d)=>d.data())
        .toList();
  }

  //==================================================
  // Recommendations
  //==================================================
  Future<List<RecommendedAttraction>>
      getRecommendations() async {

    final attractions =
        await fetchAttractions();

    if(attractions.isEmpty) return [];

    final prefs =
        await _fetchUserPrefs();

    final actLog =
        await _fetchActivityLog();

    final allTrips =
        await _fetchAllTrips();

    //------------------------------------------
    // read user interests from travel_style
    //------------------------------------------
    final travelStyle =
       prefs['travel_style'] ?? {};

    final userInterests =
      List<String>.from(
        travelStyle['interests'] ?? []
      );

    final userPace =
      travelStyle['pace'] ?? '';

    //------------------------------------------
    // exclude already saved places
    //------------------------------------------
    final seenIds = actLog
        .where(
          (e)=>
           [
             'attraction_added_to_cart',
             'save'
           ].contains(
             e['action_type']
           ),
        )
        .map(
          (e)=>
             e['item_id'] as String? ?? '',
        )
        .toSet();

    //------------------------------------------
    // Personalized Scoring
    //------------------------------------------
    Map<String,double>
      personalisedScore={};

    for(final a in attractions){

      double score=0;

      // priority by interest order
      int interestIndex =
       userInterests.indexWhere(
         (i)=>
          i.toLowerCase()==
          a.category.toLowerCase()
       );

      if(interestIndex!=-1){
        // first selected interest gets highest priority
        score +=
         (100 - (interestIndex*10));
      }

      // pace preference
      if(
        userPace.isNotEmpty &&
        a.pace.toLowerCase()==
        userPace.toLowerCase()
      ){
        score +=20;
      }

      // boost high rated attractions
      score += a.rating * 5;

      if(score>0){
        personalisedScore[a.id]=score;
      }
    }

    //------------------------------------------
    // Collaborative Filtering
    //------------------------------------------
    final userLikedIds=actLog
      .where(
        (e)=>
         e['action_type']=='like'
      )
      .map(
        (e)=>
          e['item_id'] as String? ?? ''
      )
      .toSet();

    Map<String,double> cfScore={};

    for(final trip in allTrips){

      final selected=
       List<String>.from(
        trip['generation_metadata']
             ?['selected_by_user']
             ?? []
       );

      final overlap=
         selected.where(
          (id)=>
            userLikedIds.contains(id)
         ).length;

      if(overlap>0){

        for(final id in selected){

          if(!userLikedIds.contains(id)){

            cfScore[id]=
              (cfScore[id] ?? 0)
              + overlap.toDouble();
          }
        }
      }
    }

    //------------------------------------------
    // Merge Scores
    //------------------------------------------
    List<RecommendedAttraction>
       results=[];

    for(final a in attractions){

      if(seenIds.contains(a.id)){
        continue;
      }

      final ps=
        personalisedScore[a.id] ?? 0;

      final cs=
        cfScore[a.id] ?? 0;

      double finalScore;
      RecTag tag;

      if(ps>0 && cs>0){
        finalScore =
          ps*1.5 + cs;

        tag=
         RecTag.personalised;
      }

      else if(ps>0){
        finalScore=ps;
        tag=
         RecTag.personalised;
      }

      else if(cs>0){
        finalScore=cs;
        tag=
         RecTag.itemCF;
      }

      else{
        finalScore=a.rating;
        tag=
         RecTag.popular;
      }

      results.add(
        RecommendedAttraction(
          a,
          finalScore,
          tag,
        )
      );
    }

    //------------------------------------------
    // Sort highest score first
    //------------------------------------------
    results.sort(
      (a,b)=>
       b.score.compareTo(
        a.score
       )
    );

    return results
        .take(10)
        .toList();
  }

  //==================================================
  // Activity Logger
  //==================================================
  Future<void> logAction(
    String itemId,
    String actionType,
    String itemType,
  ) async {

    if(_uid==null) return;

    await _db
      .collection('activity_log')
      .add({

        'user_id':_uid,
        'item_id':itemId,
        'action_type':actionType,
        'item_type':itemType,

        'timestamp':
          FieldValue.serverTimestamp(),
      });
  }
}
