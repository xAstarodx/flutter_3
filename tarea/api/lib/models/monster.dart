class Monster {
  final int id;
  final String name;
  final String type;
  final String species;
  final String description;

  Monster({
    required this.id,
    required this.name,
    required this.type,
    required this.species,
    required this.description,
  });

  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      id: json['id'],
      name: json['name'],
      type: json['status'] ?? 'Desconocido',
      species: json['species'] ?? 'Desconocido',
      description:
          'Género: ${json['gender']}\n'
          'Origen: ${json['origin']['name'] ?? 'Desconocido'}\n'
          'Ubicación: ${json['location']['name'] ?? 'Desconocido'}',
    );
  }
}
