class Event {
  final String eventName;
  final String imageUrl;

  Event({required this.eventName, required this.imageUrl});

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventName: map['eventName'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }
}
