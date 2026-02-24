import 'package:email_validator/email_validator.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    if (!EmailValidator.validate(value)) {
      return 'Неверный email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя';
    }
    if (value.length < 2) {
      return 'Имя должно быть не менее 2 символов';
    }
    return null;
  }

  static String? validateLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите логин';
    }
    if (value.length < 3) {
      return 'Логин должен быть не менее 3 символов';
    }
    return null;
  }
}
