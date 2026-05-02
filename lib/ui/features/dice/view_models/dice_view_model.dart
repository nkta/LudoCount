import 'package:flutter/foundation.dart';

class DiceViewModel extends ChangeNotifier {
  int _diceCount = 1;
  int get diceCount => _diceCount;

  void setCount(int count) {
    _diceCount = count;
    notifyListeners();
  }
}
