import 'package:flutter/material.dart';
import '../models/monster.dart';
import '../services/monster_service.dart';
import '../widgets/monster_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Monster> _allMonsters = [];
  List<Monster> _filteredMonsters = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  final Map<String, String?> _categories = {
    'Todo': null,
    'Vivos': 'Alive',
    'Muertos': 'Dead',
    'Desconocidos': 'unknown',
  };
  late String _selectedCategoryKey;

  @override
  void initState() {
    super.initState();
    _selectedCategoryKey = _categories.keys.first;
    _fetchMonsters();
    _searchController.addListener(_filterMonsters);
  }

  Future<void> _fetchMonsters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final monsters = await MonsterService.fetchMonsters();
      setState(() {
        _allMonsters = monsters;
        _filteredMonsters = monsters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterMonsters() {
    String query = _searchController.text.toLowerCase().trim();
    final selectedType = _categories[_selectedCategoryKey];

    setState(() {
      _filteredMonsters = _allMonsters.where((monster) {
        final nameMatches = monster.name.toLowerCase().contains(query);

        final categoryMatches =
            selectedType == null || monster.type == selectedType;
        return nameMatches && categoryMatches;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMonsters);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rick & Morty ')),
      body: Column(
        children: [
          _buildControls(),
          Expanded(child: _buildMonsterList()),
        ],
      ),
    );
  }

  Widget _buildMonsterList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }
    if (_filteredMonsters.isEmpty) {
      return const Center(child: Text('No se encontro nada.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredMonsters.length,
      itemBuilder: (context, index) {
        final monster = _filteredMonsters[index];
        return MonsterCard(monster: monster);
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedCategoryKey,
            decoration: InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: _categories.keys.map((String categoryKey) {
              return DropdownMenuItem<String>(
                value: categoryKey,
                child: Text(categoryKey.toUpperCase()),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategoryKey = newValue!;
              });
              _filterMonsters();
            },
          ),
        ],
      ),
    );
  }
}
