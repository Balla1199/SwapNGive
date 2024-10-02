class NotificationModel {
  String id;
  String fromUserId; // L'utilisateur qui fait la proposition (utilisateur2)
  String toUserId; // L'utilisateur qui reçoit la proposition (utilisateur1)
  String titre;
  String message;
  DateTime date;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.titre,
    required this.message,
    required this.date,
    this.isRead = false,
  });

  // Convertir une notification en Map (pour Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'titre': titre,
      'message': message,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Créer une notification à partir de Map (depuis Firebase)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      fromUserId: map['fromUserId'],
      toUserId: map['toUserId'],
      titre: map['titre'],
      message: map['message'],
      date: DateTime.parse(map['date']),
      isRead: map['isRead'] ?? false,
    );
  }
}
