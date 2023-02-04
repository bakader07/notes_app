import './loading_screen_controller.dart';

class LoadingScreen {
  static final LoadingScreen _loadingScreen = LoadingScreen._instance();
  factory LoadingScreen() => _loadingScreen;
  LoadingScreen._instance();

  LoadingScreenController? controller;
}
