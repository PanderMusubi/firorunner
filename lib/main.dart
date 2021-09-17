import 'dart:math';

import 'package:firo_runner/bug_holder.dart';
import 'package:firo_runner/circuit_background.dart';
import 'package:firo_runner/coin_holder.dart';
import 'package:firo_runner/debris_holder.dart';
import 'package:firo_runner/firework.dart';
import 'package:firo_runner/game_state.dart';
import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/platform.dart';
import 'package:firo_runner/platform_holder.dart';
import 'package:firo_runner/wire.dart';
import 'package:firo_runner/wire_holder.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firo_runner/runner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const COLOR = Color(0xFFDDC0A3);

const LEVEL2 = 10000000;
const LEVEL3 = 20000000;
const LEVEL4 = 30000000;
const LEVEL5 = 40000000;
const LEVEL6 = 50000000;
const LEVEL7 = 60000000;

const RUNNER_PRIORITY = 100;
const BUG_PRIORITY = 75;
const COIN_PRIORITY = 70;
const PLATFORM_PRIORITY = 50;
const DEBRIS_PRIORITY = 30;
const WIRE_PRIORITY = 25;
const FIREWORK_PRIORITY = 15;
const WINDOW_PRIORITY = 10;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  final myGame = MyGame();
  runApp(GameWidget(game: myGame));
}

int getNearestPlatform(int level) {
  return level <= 0
      ? 0
      : level <= 3
          ? 2
          : level <= 6
              ? 5
              : 8;
}

class MyGame extends BaseGame with PanDetector, TapDetector, KeyboardEvents {
  TextPaint fireworksPaint = TextPaint(
    config: const TextPaintConfig(
        fontSize: 48.0, fontFamily: 'Codystar', color: COLOR),
  );

  late CircuitBackground circuitBackground;
  late PlatformHolder platformHolder;
  late CoinHolder coinHolder;
  late WireHolder wireHolder;
  late BugHolder bugHolder;
  late Firework fireworks;
  late DebrisHolder debrisHolder;
  Random random = Random();
  bool playingMusic = false;

  late Runner runner;
  late GameState gameState;
  late double blockSize;

  bool loaded = false;
  late Wire wire;

  MyGame() : super() {
    viewport.resize(Vector2(1920, 1080));
  }

  // @override
  // flame.Viewport viewport = FixedResolutionViewport(Vector2(1920, 1080));

  @override
  Future<void> onLoad() async {
    // debugMode = true;
    FlameAudio.bgm.initialize();

    circuitBackground = CircuitBackground(this);
    await circuitBackground.load();
    platformHolder = PlatformHolder();
    await platformHolder.load();
    coinHolder = CoinHolder();
    await coinHolder.load();
    wireHolder = WireHolder();
    await wireHolder.load();
    bugHolder = BugHolder();
    await bugHolder.load();
    debrisHolder = DebrisHolder();
    await debrisHolder.load();
    fireworks = Firework(this);
    await fireworks.load();

    gameState = GameState();

    runner = Runner();
    await runner.load(loadSpriteAnimation);

    if (!kIsWeb) {
      playMusic();
    }
    loaded = true;
    setUp();
  }

  void playMusic() {
    FlameAudio.bgm.play('Infinite_Spankage_M.mp3');
    playingMusic = true;
  }

  void fillScreen() {
    if (shouldReset) {
      return;
    }

    platformHolder.generatePlatforms(this);

    int wireChosenRegion = random.nextInt(9);
    if (wireChosenRegion % 3 != 2 &&
        wireChosenRegion != 6 &&
        wireChosenRegion != 7) {
      wireHolder.generateWire(this, wireChosenRegion, false);
    }

    int bugChosenRegion = random.nextInt(9);
    if (bugChosenRegion % 3 != 2 && bugChosenRegion % 3 != 0) {
      bugHolder.generateBug(this, bugChosenRegion, false);
    }

    int debrisChosenRegion = random.nextInt(9);
    if (debrisChosenRegion % 3 == 0 && debrisChosenRegion != 6) {
      debrisHolder.generateDebris(this, debrisChosenRegion, false);
    }

    int choseCoinLevel = random.nextInt(9);
    if (choseCoinLevel % 3 != 2 && choseCoinLevel != 6) {
      coinHolder.generateCoin(this, choseCoinLevel, false);
    }
  }

  bool isTooNearOtherObstacles(Rect rect) {
    Rect obstacleBounds = Rect.fromLTRB(
        3 * rect.left - 2 * rect.right - 1,
        3 * rect.top - 2 * rect.bottom - 1,
        3 * rect.right - 2 * rect.left + 1,
        3 * rect.bottom - 2 * rect.top + 1);
    for (List<MovingObject> wireLevel in wireHolder.objects) {
      for (MovingObject wire in wireLevel) {
        if (wire.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<MovingObject> coinLevel in coinHolder.objects) {
      for (MovingObject coin in coinLevel) {
        if (coin.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<MovingObject> bugLevel in bugHolder.objects) {
      for (MovingObject bug in bugLevel) {
        if (bug.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<MovingObject> debrisLevel in debrisHolder.objects) {
      for (MovingObject debris in debrisLevel) {
        if (debris.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    return false;
  }

  bool shouldReset = false;

  void reset() {
    if (!(runner.sprite.animation?.done() ?? false) &&
        runner.sprite.animation!.loop == false) {
      return;
    }
    runner.sprite.animation!.reset();
    shouldReset = false;
    components.clear();
    setUp();
  }

  void die() {
    gameState.setPaused();
    shouldReset = true;
  }

  void setUp() {
    add(runner);
    fireworks.setUp();
    runner.sprite.clearEffects();
    runner.sprite.current = RunnerState.run;
    circuitBackground.setUp();
    platformHolder.setUp();
    coinHolder.setUp();
    wireHolder.setUp();
    bugHolder.setUp();
    debrisHolder.setUp();

    gameState.setUp(this);

    runner.setUp();

    fillScreen();
    platformHolder.objects[2][0].sprite.current = PlatformState.left;
    platformHolder.objects[5][0].sprite.current = PlatformState.left;
  }

  @override
  void render(Canvas canvas) {
    circuitBackground.render(canvas);
    fireworks.renderText(canvas);
    super.render(canvas);
    final fpsCount = fps(10000);
    fireworksPaint.render(
      canvas,
      fpsCount.toString(),
      Vector2(0, 0),
    );
  }

  @override
  void update(double dt) {
    fireworks.update(dt);
    platformHolder.removePast(this);
    coinHolder.removePast(this);
    wireHolder.removePast(this);
    bugHolder.removePast(this);
    debrisHolder.removePast(this);
    fillScreen();
    super.update(dt);
    circuitBackground.update(dt);
    gameState.update(dt);
    platformHolder.update(dt);
    coinHolder.update(dt);
    wireHolder.update(dt);
    bugHolder.update(dt);
    debrisHolder.update(dt);
    if (shouldReset) {
      reset();
    }
  }

  @override
  void onResize(Vector2 canvasSize) {
    Vector2 oldSize = viewport.canvasSize;
    super.onResize(canvasSize);
    blockSize = canvasSize.y / 9;
    if (loaded) {
      double xRatio = canvasSize.x / oldSize.x;
      double yRatio = canvasSize.y / oldSize.y;
      circuitBackground.resize(canvasSize, xRatio, yRatio);
      runner.resize(canvasSize, xRatio, yRatio);
      platformHolder.resize(canvasSize, xRatio, yRatio);
      coinHolder.resize(canvasSize, xRatio, yRatio);
      wireHolder.resize(canvasSize, xRatio, yRatio);
      bugHolder.resize(canvasSize, xRatio, yRatio);
      debrisHolder.resize(canvasSize, xRatio, yRatio);
      fireworks.resize(canvasSize, xRatio, yRatio);
    }
  }

  // Mobile controls
  late List<double> xDeltas;
  late List<double> yDeltas;
  @override
  void onPanStart(DragStartInfo info) {
    xDeltas = List.empty(growable: true);
    yDeltas = List.empty(growable: true);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    xDeltas.add(info.delta.game.x);
    yDeltas.add(info.delta.game.y);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (!playingMusic && kIsWeb) {
      playMusic();
    }
    double xDelta = xDeltas.isEmpty
        ? 0
        : xDeltas.reduce((value, element) => value + element);
    double yDelta = yDeltas.isEmpty
        ? 0
        : yDeltas.reduce((value, element) => value + element);
    if (xDelta.abs() > yDelta.abs()) {
      if (xDelta > 0) {
        runner.control("right");
      } else {
        runner.control("left");
      }
    } else if (xDelta.abs() < yDelta.abs()) {
      if (yDelta > 0) {
        runner.control("down");
      } else {
        runner.control("up");
      }
    }
  }

  @override
  void onTap() {
    if (!playingMusic && kIsWeb) {
      playMusic();
    }
    runner.control("center");
  }

  // Keyboard controls.
  var keyboardKey;
  @override
  void onKeyEvent(RawKeyEvent event) {
    if (!playingMusic && kIsWeb) {
      playMusic();
    }
    print(event.data.logicalKey.keyId);
    print(event.data.keyLabel);
    if (event is RawKeyUpEvent) {
      keyboardKey = null;
      switch (event.data.keyLabel) {
        case "w":
          runner.control("up");
          break;
        case "a":
          runner.control("left");
          break;
        case "s":
          runner.control("down");
          break;
        case "d":
          runner.control("right");
          break;
        default:
          if (event.data.logicalKey.keyId == 32) {
            runner.control("down");
          }
          break;
      }
    }
    if (event is RawKeyDownEvent && event.data.logicalKey.keyId == 32) {
      if (keyboardKey == null) {
        runner.control("center");
      }
      keyboardKey = "spacebar";
    }
  }
}
