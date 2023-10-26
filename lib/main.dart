import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_template/ember_quest.dart';

void main() {
  runApp(
    const GameWidget<EmberQuestGame>.controlled(
      gameFactory: EmberQuestGame.new,
    ),
  );
}
