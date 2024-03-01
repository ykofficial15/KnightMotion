import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knightmotion/Model/userHomeModel.dart';

class EventController extends ChangeNotifier{
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('Template');

  Future<List<Event>> fetchEvents() async {
    List<Event> events = [];
    try {
      QuerySnapshot snapshot = await eventsCollection.get();
      snapshot.docs.forEach((doc) {
        events.add(Event.fromMap(doc.data() as Map<String, dynamic>));
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
    return events;
  }
}
