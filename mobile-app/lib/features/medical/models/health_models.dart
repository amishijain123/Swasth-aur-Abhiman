class BPReading {
  final String? id;
  final DateTime date;
  final int systolic;
  final int diastolic;
  final int? pulse;

  BPReading({
    this.id,
    required this.date,
    required this.systolic,
    required this.diastolic,
    this.pulse,
  });

  factory BPReading.fromJson(Map<String, dynamic> json) {
    return BPReading(
      id: json['id'],
      date: DateTime.parse(json['date']),
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      pulse: json['pulse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
    };
  }

  String get status {
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'High BP Stage 1';
    if (systolic >= 140 || diastolic >= 90) return 'High BP Stage 2';
    return 'Unknown';
  }
}

class SugarReading {
  final String? id;
  final DateTime date;
  final double level;
  final String type; // FASTING, RANDOM, POST_MEAL

  SugarReading({
    this.id,
    required this.date,
    required this.level,
    required this.type,
  });

  factory SugarReading.fromJson(Map<String, dynamic> json) {
    return SugarReading(
      id: json['id'],
      date: DateTime.parse(json['date']),
      level: (json['level'] as num).toDouble(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'level': level,
      'type': type,
    };
  }

  String get status {
    if (type == 'FASTING') {
      if (level < 100) return 'Normal';
      if (level < 126) return 'Pre-diabetic';
      return 'Diabetic';
    } else {
      if (level < 140) return 'Normal';
      if (level < 200) return 'Pre-diabetic';
      return 'Diabetic';
    }
  }
}

class BMIReading {
  final String? id;
  final DateTime date;
  final double weight; // kg
  final double height; // cm
  final double bmi;

  BMIReading({
    this.id,
    required this.date,
    required this.weight,
    required this.height,
    required this.bmi,
  });

  factory BMIReading.fromJson(Map<String, dynamic> json) {
    return BMIReading(
      id: json['id'],
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'height': height,
      'bmi': bmi,
    };
  }

  static double calculateBMI(double weight, double heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  String get status {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}

class HealthMetrics {
  final List<BPReading> bpHistory;
  final List<SugarReading> sugarHistory;
  final List<BMIReading> bmiHistory;

  HealthMetrics({
    this.bpHistory = const [],
    this.sugarHistory = const [],
    this.bmiHistory = const [],
  });

  factory HealthMetrics.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return HealthMetrics();
    }
    return HealthMetrics(
      bpHistory: (json['bpHistory'] as List<dynamic>?)
              ?.map((e) => BPReading.fromJson(e))
              .toList() ??
          [],
      sugarHistory: (json['sugarHistory'] as List<dynamic>?)
              ?.map((e) => SugarReading.fromJson(e))
              .toList() ??
          [],
      bmiHistory: (json['bmiHistory'] as List<dynamic>?)
              ?.map((e) => BMIReading.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bpHistory': bpHistory.map((e) => e.toJson()).toList(),
      'sugarHistory': sugarHistory.map((e) => e.toJson()).toList(),
      'bmiHistory': bmiHistory.map((e) => e.toJson()).toList(),
    };
  }
}

class HerbalRemedy {
  final String name;
  final String condition;
  final String description;
  final String usage;
  final String imageUrl;

  HerbalRemedy({
    required this.name,
    required this.condition,
    required this.description,
    required this.usage,
    required this.imageUrl,
  });
}

// Post-COVID recovery focused herbal remedies
class HerbalRemedies {
  static List<HerbalRemedy> get remedies => [
    HerbalRemedy(
      name: 'Tulsi (Holy Basil)',
      condition: 'Immunity & Respiratory Health',
      description: 'Tulsi is known for its immunomodulatory properties. It helps strengthen the respiratory system and is particularly beneficial for post-COVID recovery.',
      usage: 'Drink tulsi tea 2-3 times daily. Add fresh leaves to warm water with honey.',
      imageUrl: 'assets/herbs/tulsi.png',
    ),
    HerbalRemedy(
      name: 'Ashwagandha',
      condition: 'Fatigue & Stress',
      description: 'Ashwagandha helps combat post-COVID fatigue and stress. It is an adaptogen that helps the body cope with stress.',
      usage: 'Take 1-2 grams of powder with warm milk before bedtime.',
      imageUrl: 'assets/herbs/ashwagandha.png',
    ),
    HerbalRemedy(
      name: 'Giloy (Guduchi)',
      condition: 'Immunity Booster',
      description: 'Giloy is a powerful immunomodulator that helps boost immunity and aids in recovery from infections.',
      usage: 'Consume giloy juice or kadha daily in the morning.',
      imageUrl: 'assets/herbs/giloy.png',
    ),
    HerbalRemedy(
      name: 'Amla (Indian Gooseberry)',
      condition: 'Vitamin C & Immunity',
      description: 'Amla is rich in Vitamin C and antioxidants. It helps in strengthening immunity and fighting infections.',
      usage: 'Consume fresh amla or amla juice daily. Can be taken as churna with honey.',
      imageUrl: 'assets/herbs/amla.png',
    ),
    HerbalRemedy(
      name: 'Moringa (Drumstick)',
      condition: 'Anemia in Women',
      description: 'Moringa leaves are rich in iron and are highly beneficial for treating anemia, especially in women. Also helps in post-COVID weakness.',
      usage: 'Add moringa leaves to soups or consume as powder with warm water.',
      imageUrl: 'assets/herbs/moringa.png',
    ),
    HerbalRemedy(
      name: 'Turmeric (Haldi)',
      condition: 'Anti-inflammatory',
      description: 'Turmeric has powerful anti-inflammatory and antioxidant properties. Helps reduce inflammation and supports recovery.',
      usage: 'Drink golden milk (haldi doodh) daily. Add to food preparations.',
      imageUrl: 'assets/herbs/turmeric.png',
    ),
    HerbalRemedy(
      name: 'Mulethi (Licorice)',
      condition: 'Throat & Cough',
      description: 'Mulethi soothes the throat and helps with persistent cough, common in post-COVID conditions.',
      usage: 'Chew small piece of mulethi root or add to warm water as tea.',
      imageUrl: 'assets/herbs/mulethi.png',
    ),
    HerbalRemedy(
      name: 'Beetroot',
      condition: 'Anemia & Blood Health',
      description: 'Beetroot is rich in iron and folic acid, making it excellent for treating anemia and improving blood health.',
      usage: 'Consume beetroot juice or add to salads. Best taken on empty stomach.',
      imageUrl: 'assets/herbs/beetroot.png',
    ),
  ];
}
