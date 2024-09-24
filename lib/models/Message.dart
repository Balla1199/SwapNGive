class Message {
  String contenu;
  String expediteurId;
  String destinataireId;
  String echangeId;
  DateTime dateEnvoi;

  Message({
    required this.contenu,
    required this.expediteurId,
    required this.destinataireId,
    required this.echangeId,
    required this.dateEnvoi,
  });

  // Convertir l'objet Message en JSON
  Map<String, dynamic> toJson() {
    return {
      'contenu': contenu,
      'expediteurId': expediteurId,
      'destinataireId': destinataireId,
      'echangeId': echangeId,
      'dateEnvoi': dateEnvoi.toIso8601String(),
    };
  }

  // Créer un objet Message à partir de JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      contenu: json['contenu'],
      expediteurId: json['expediteurId'],
      destinataireId: json['destinataireId'],
      echangeId: json['echangeId'],
      dateEnvoi: DateTime.parse(json['dateEnvoi']),
    );
  }
}
