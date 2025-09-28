import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class CameraView extends StatefulWidget {
  CameraView({
    Key? key,
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.back,
  }) : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;
  bool _isStreaming = false;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLiveFeed();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _stopLiveFeed();
    } else if (state == AppLifecycleState.resumed) {
      _startLiveFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_controller == null || !_controller!.value.isInitialized || !_isControllerInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<CameraValue>(
      valueListenable: _controller!,
      builder: (context, value, child) {
        if (!_controller!.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CameraPreview(_controller!, child: widget.customPaint),
              // _switchLiveCameraToggle(),//反转摄像头
            ],
          ),
        );
      },
    );
  }

  Widget _switchLiveCameraToggle() => Positioned(
    bottom: 8,
    right: 8,
    child: SizedBox(
      height: 50.0,
      width: 50.0,
      child: FloatingActionButton(
        heroTag: Object(),
        onPressed: _switchLiveCamera,
        backgroundColor: Colors.black54,
        child: Icon(
          Platform.isIOS ? Icons.flip_camera_ios_outlined : Icons.flip_camera_android_outlined,
          size: 25,
        ),
      ),
    ),
  );

  Future _startLiveFeed() async {
    if (_controller != null) {
      await _controller?.dispose();
      _controller = null;
    }

    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    _controller?.addListener(() {
      if (!mounted) return;
      if (_controller!.value.hasError) {
        debugPrint('Camera error: ${_controller!.value.errorDescription}');
      }
    });

    try {
      await _controller!.initialize();

      _currentZoomLevel = await _controller!.getMinZoomLevel();
      _minAvailableZoom = _currentZoomLevel;
      _maxAvailableZoom = await _controller!.getMaxZoomLevel();

      _currentExposureOffset = 0.0;
      _minAvailableExposureOffset = await _controller!.getMinExposureOffset();
      _maxAvailableExposureOffset = await _controller!.getMaxExposureOffset();

      await _controller!.startImageStream(_processCameraImage);
      _isStreaming = true;

      widget.onCameraFeedReady?.call();
      widget.onCameraLensDirectionChanged?.call(camera.lensDirection);

      setState(() {
        _isControllerInitialized = true;
      });
    } catch (e) {
      debugPrint('❌ Failed to start live feed: $e');
      setState(() {
        _isControllerInitialized = false;
      });
    }
  }

  Future<void> _stopLiveFeed() async {
    try {
      if (_isStreaming) {
        await _controller?.stopImageStream();
        _isStreaming = false;
      }
    } catch (e) {
      debugPrint("stopImageStream error: $e");
    }

    await _controller?.dispose();
    _controller = null;

    Future.microtask(() {
      if (mounted) {
        setState(() {
          _isControllerInitialized = false;
        });
      }
    });
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
