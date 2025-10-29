class PhotoModel {
  final String id;
  final String path;
  final DateTime dateTaken;

  PhotoModel({required this.id, required this.path, required this.dateTaken});

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'dateTaken': dateTaken.toIso8601String(),
  };

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
    id: json['id'],
    path: json['path'],
    dateTaken: DateTime.parse(json['dateTaken']),
  );
}
