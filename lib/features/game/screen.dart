import 'package:flutter/material.dart';
import 'package:redstring/features/game/models/game_state.dart';
import 'package:redstring/features/game/widgets/gradient_background.dart';
import 'package:redstring/features/game/widgets/next_arrow_button.dart';
import 'package:redstring/features/game/widgets/option_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<GameScreen> {
  GamePhase _currentPhase = GamePhase.setup;

  final _questionController = TextEditingController();
  final _optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  int _selectedCorrectOptionIndex = 0;
  int _userAnswerIndex = -1;
  bool _isCorrect = false;

  QuizQuestion? _currentQuestion;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildSetupScreen() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            "Придумай вопрос",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _questionController,
              maxLines: null,
              minLines: 1,
              decoration: InputDecoration(
                hintText: "Текст вопроса...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          ...List.generate(4, (index) {
            final isSelected = _selectedCorrectOptionIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedCorrectOptionIndex = index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFA6B1E1)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFA6B1E1)
                                : Colors.grey,
                            width: 2,
                          ),
                          color: isSelected
                              ? const Color(0xFFA6B1E1)
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _optionControllers[index],
                          maxLines: null,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: "Вариант ${index + 1}",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: _saveQuestionAndProceed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA6B1E1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Готово",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayScreen() {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Text(
          "Раунд 1",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _currentQuestion!.questionText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: null,
          ),
        ),
        const SizedBox(height: 40),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: List.generate(4, (index) {
                return OptionButton(
                  text: _currentQuestion!.options[index],
                  isSelected: _userAnswerIndex == index,
                  onTap: () {
                    setState(() => _userAnswerIndex = index);
                  },
                );
              }),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: NextArrowButton(onPressed: _checkAnswer),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: _isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            _isCorrect ? "Правильно!" : "Мимо!",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (!_isCorrect)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Правильный ответ: ${_currentQuestion!.options[_currentQuestion!.correctOptionIndex]}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          const SizedBox(height: 60),
          NextArrowButton(onPressed: _goToMain),
        ],
      ),
    );
  }

  void _saveQuestionAndProceed() {
    if (_questionController.text.isEmpty) {
      _showSnackBar("Введите текст вопроса");
      return;
    }

    for (var controller in _optionControllers) {
      if (controller.text.isEmpty) {
        _showSnackBar("Заполните все варианты ответов");
        return;
      }
    }

    setState(() {
      _currentQuestion = QuizQuestion(
        questionText: _questionController.text,
        options: _optionControllers.map((c) => c.text).toList(),
        correctOptionIndex: _selectedCorrectOptionIndex,
      );
      _currentPhase = GamePhase.playing;
      _userAnswerIndex = -1;
    });
  }

  void _checkAnswer() {
    if (_userAnswerIndex == -1) {
      _showSnackBar("Выберите вариант ответа");
      return;
    }

    setState(() {
      _isCorrect = (_userAnswerIndex == _currentQuestion!.correctOptionIndex);
      _currentPhase = GamePhase.result;
    });
  }

  void _resetGame() {
    setState(() {
      _currentPhase = GamePhase.setup;
      _questionController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
      _selectedCorrectOptionIndex = 0;
      _userAnswerIndex = -1;
      _currentQuestion = null;
    });
  }

  void _goToMain() {
    Navigator.of(context).pop();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFA6B1E1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFA6B1E1),
            ),
            onPressed: _goToMain,
          ),
        ),
        body: _currentPhase == GamePhase.setup
            ? _buildSetupScreen()
            : _currentPhase == GamePhase.playing
            ? _buildPlayScreen()
            : _buildResultScreen(),
      ),
    );
  }
}
