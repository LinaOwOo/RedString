import 'package:flutter/material.dart';
import 'data/date_ideas.dart';
import 'models/adventure_state.dart';
import 'widgets/scratch_idea_card.dart';

class AdventureScreen extends StatefulWidget {
  const AdventureScreen({super.key});

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  String? _currentIdea;
  int _usedCount = 0;
  bool _isLoading = true;
  bool _showLimit = false;

  @override
  void initState() {
    super.initState();
    _loadNextIdea();
  }

  Future<void> _loadNextIdea() async {
    setState(() {
      _isLoading = true;
      _showLimit = false;
    });

    final state = await AdventureState.load();
    _usedCount = state.usedIdeaIds.length;

    _getTodayString();

    if (!state.canViewToday()) {
      setState(() {
        _showLimit = true;
        _isLoading = false;
      });
      return;
    }

    if (state.hasSeenAllIdeas()) {
      await AdventureState.initial().save();
      return _loadNextIdea();
    }

    final allIds = List<int>.generate(dateIdeas.length, (i) => i);
    final availableIds = allIds
        .where((id) => !state.usedIdeaIds.contains(id))
        .toList();

    if (availableIds.isEmpty) {
      _currentIdea = 'Все идеи просмотрены! Начнём заново?';
    } else {
      final randomIndex =
          DateTime.now().microsecondsSinceEpoch % availableIds.length;
      final selectedId = availableIds[randomIndex];
      _currentIdea = dateIdeas[selectedId];

      final newState = state.updateAfterView().copyWith(
        usedIdeaIds: [...state.usedIdeaIds, selectedId],
      );
      _usedCount = newState.usedIdeaIds.length;
      await newState.save();
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _getTodayString() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  void _onIdeaRevealed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text('Идея раскрыта! До завтра 💕'),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Приключение на день'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_usedCount / ${dateIdeas.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const CircularProgressIndicator()
            else if (_showLimit)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Вы уже открыли 2 идеи сегодня.\nЗагляните сюда завтра!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, height: 1.5),
                      ),
                    ],
                  ),
                ),
              )
            else if (_currentIdea != null)
              ScratchIdeaCard(idea: _currentIdea!, onReveal: _onIdeaRevealed)
            else
              const Text('Не удалось загрузить идею...'),
          ],
        ),
      ),
    );
  }
}
