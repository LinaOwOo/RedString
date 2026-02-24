class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // Индекс правильного ответа (0-3)

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
}

// Состояние игры (можно добавить в adventure_state.dart)
enum GamePhase {
  setup, // Первый пользователь придумывает вопрос
  playing, // Второй пользователь отвечает
  result, // Показ результата
}
