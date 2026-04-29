class SymptomLogModel {
  SymptomLogModel({
    required this.id,
    required this.dateIso,
    required this.symptoms,
    this.notes = '',
  });

  final String id;
  final String dateIso;
  final List<String> symptoms;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': dateIso,
        'symptoms': symptoms,
        'notes': notes,
      };

  factory SymptomLogModel.fromJson(Map<String, dynamic> json) => SymptomLogModel(
        id: json['id'] as String? ?? '',
        dateIso: json['date'] as String? ?? '',
        symptoms: ((json['symptoms'] as List?) ?? []).map((e) => e.toString()).toList(),
        notes: json['notes'] as String? ?? '',
      );
}
