class Prescription {
  final String id;
  final String userId;
  final String? patientName;
  final String? block;
  final String imageUrl;
  final String? description;
  final String? symptoms;
  final String status;
  final String? reviewedById;
  final String? doctorNotes;
  final String? suggestedMedicines;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  Prescription({
    required this.id,
    required this.userId,
    this.patientName,
    this.block,
    required this.imageUrl,
    this.description,
    this.symptoms,
    required this.status,
    this.reviewedById,
    this.doctorNotes,
    this.suggestedMedicines,
    required this.createdAt,
    this.reviewedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      userId: json['user']?['id'] ?? json['userId'] ?? '',
      patientName: json['user']?['name'] ?? json['patientName'],
      block: json['user']?['block'] ?? json['block'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      symptoms: json['symptoms'],
      status: json['status'],
      reviewedById: json['reviewedBy']?['id'],
      doctorNotes: json['doctorNotes'],
      suggestedMedicines: json['suggestedMedicines'],
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null 
          ? DateTime.parse(json['reviewedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'description': description,
      'symptoms': symptoms,
      'status': status,
      'doctorNotes': doctorNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isReviewed => status == 'REVIEWED';
}

class CreatePrescriptionRequest {
  final String imageUrl;
  final String? description;
  final String? symptoms;

  CreatePrescriptionRequest({
    required this.imageUrl,
    this.description,
    this.symptoms,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'description': description,
      'symptoms': symptoms,
    };
  }
}

class ReviewPrescriptionRequest {
  final String doctorNotes;

  ReviewPrescriptionRequest({required this.doctorNotes});

  Map<String, dynamic> toJson() {
    return {
      'doctorNotes': doctorNotes,
    };
  }
}
