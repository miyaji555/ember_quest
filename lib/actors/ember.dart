import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/actors/water_enemy.dart';

import '../ember_quest.dart';
import '../objects/ground_block.dart';
import '../objects/platform_block.dart';
import '../objects/star.dart';

class EmberPlayer extends SpriteAnimationComponent
    with KeyboardHandler, HasGameRef<EmberQuestGame>, CollisionCallbacks {
  EmberPlayer({
    required super.position,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  final Vector2 fromAbove = Vector2(0, -1);
  bool isOnGround = false;
  final double gravity = 15;
  double velocityOffsetOnKeyboard = 0;
  double velocityOffsetOnJoystick = 0;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;

  bool hasJumpedOnKeyboard = false;
  bool hasJumpedOnJoystick = false;
  bool hitByEnemy = false;

  int horizontalDirection = 0;
  int horizontalDirectionOnKeyboard = 0;
  int horizontalDirectionOnJoystick = 0;

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );
    add(
      CircleHitbox(),
    );
  }

  @override
  void update(double dt) {
    onJoystickEvent();
    velocity.x = horizontalDirection * moveSpeed;
    position += velocity * dt;
    // Apply basic gravity
    velocity.y += gravity;

// Determine if ember has jumped
    if (hasJumpedOnKeyboard || hasJumpedOnJoystick) {
      hasJumpedOnKeyboard = true;
      hasJumpedOnJoystick = true;
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
      hasJumpedOnJoystick = false;
      hasJumpedOnKeyboard = false;
    }

// Prevent ember from jumping to crazy fast as well as descending too fast and
// crashing through the ground or a platform.
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity) +
        velocityOffsetOnJoystick +
        velocityOffsetOnKeyboard;

// Prevent ember from going backwards at screen edge.
    if (position.x - 36 <= 0 && horizontalDirection < 0) {
      velocity.x = 0;
    }
// Prevent ember from going beyond half screen.
    if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
      velocity.x = 0;
      // game.objectSpeed = -moveSpeed;
    }

    position += velocity * dt;
// If ember fell in pit, then game over.
    if (position.y > game.size.y + size.y) {
      game.health = 0;
    }

    if (game.health <= 0) {
      removeFromParent();
    }
    horizontalDirection =
        horizontalDirectionOnKeyboard + horizontalDirectionOnJoystick;
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirectionOnKeyboard = 0;
    horizontalDirectionOnKeyboard +=
        (keysPressed.contains(LogicalKeyboardKey.keyA) ||
                keysPressed.contains(LogicalKeyboardKey.arrowLeft))
            ? -1
            : 0;

    horizontalDirectionOnKeyboard +=
        (keysPressed.contains(LogicalKeyboardKey.keyD) ||
                keysPressed.contains(LogicalKeyboardKey.arrowRight))
            ? 1
            : 0;
    hasJumpedOnKeyboard = keysPressed.contains(LogicalKeyboardKey.space);
    velocityOffsetOnKeyboard =
        keysPressed.contains(LogicalKeyboardKey.arrowDown) ? 100 : 0;
    return true;
  }

  void onJoystickEvent() {
    horizontalDirectionOnJoystick = 0;
    if (game.joystick.relativeDelta[0] > 0.5) {
      horizontalDirectionOnJoystick = 1;
    }
    if (game.joystick.relativeDelta[0] < -0.5) {
      horizontalDirectionOnJoystick = -1;
    }
    hasJumpedOnJoystick = game.joystick.relativeDelta[1] < -0.5;
    velocityOffsetOnJoystick = game.joystick.relativeDelta[1] > 0.5 ? 100 : 0;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // If collision normal is almost upwards,
        // ember must be on ground.
        if (fromAbove.dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }

        // Resolve collision by moving ember along
        // collision normal by separation distance.
        position += collisionNormal.scaled(separationDistance);
      }
    }

    if (other is Star) {
      other.removeFromParent();
      game.starsCollected++;
    }

    if (other is WaterEnemy) {
      hit();
    }

    super.onCollision(intersectionPoints, other);
  }

  void hit() {
    if (!hitByEnemy) {
      game.health--;
      hitByEnemy = true;
    }
    add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.1,
          repeatCount: 5,
        ),
      )..onComplete = () {
          hitByEnemy = false;
        },
    );
  }
}
