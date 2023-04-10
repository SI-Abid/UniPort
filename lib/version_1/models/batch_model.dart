class BatchModel {
  BatchModel({
    required this.batch,
    required this.sections,
  });

  final String batch;
  final List<String> sections;

  factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
        batch: json["batch"],
        sections: List<String>.from(json["sections"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "batch": batch,
        "sections": List<dynamic>.from(sections.map((x) => x)),
      };
}