import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

const rates = [0.5, 1.0, 1.5, 2.0];

/// Widget to play audio.
class AudioPlayerWidget extends StatefulWidget {
  /// Constructor.
  const AudioPlayerWidget({
    required this.player,
    this.playIcon,
    this.pauseIcon,
    this.stopIcon,
    this.playIconSize,
    this.color,
    this.textStyle,
    this.inactiveColor,
    this.activeColor,
    this.playButtonStyle,
    this.sliderTheme,
    this.rewindIcon,
    this.forwardIcon,
    this.positionIconSize,
    this.positionButtonStyle,
    super.key,
  });

  /// Audio player.
  final AudioPlayer player;

  /// Icon to play.
  final IconData? playIcon;

  /// Icon to pause.
  final IconData? pauseIcon;

  /// Icon to stop.
  final IconData? stopIcon;

  /// Icon to rewind.
  final IconData? rewindIcon;

  /// Icon to forward.
  final IconData? forwardIcon;

  /// Icon size.
  final double? playIconSize;

  /// Position icon size
  final double? positionIconSize;

  /// Color.
  final Color? color;

  /// Active color.
  final Color? activeColor;

  /// Inactive color.
  final Color? inactiveColor;

  /// Text style.
  final TextStyle? textStyle;

  /// Button style
  final ButtonStyle? playButtonStyle;

  /// Position buttons style
  final ButtonStyle? positionButtonStyle;

  /// Slider theme
  final SliderThemeData? sliderTheme;

  @override
  State<StatefulWidget> createState() {
    return _AudioPlayerWidgetState();
  }
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  late StreamSubscription<Duration> _durationSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<void> _playerCompleteSubscription;
  late StreamSubscription<PlayerState> _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  String get _positionText => _position != null
      ? '${_position?.inMinutes.toString().padLeft(2, '0')}:${_position?.inSeconds.toString().padLeft(2, '0')}'
      : '00:00';

  Duration? get remaining => _duration! - _position!;

  String get _remainingText => remaining != null
      ? '-${remaining?.inMinutes.toString().padLeft(2, '0')}:${remaining?.inSeconds.toString().padLeft(2, '0')}'
      : '00:00';

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _playerCompleteSubscription.cancel();
    _playerStateChangeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    return Expanded(
      child: Column(
        children: <Widget>[
          SliderTheme(
            data: widget.sliderTheme ??
                const SliderThemeData(
                  trackHeight: 2,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
                ),
            child: Slider(
              activeColor: widget.activeColor ?? color,
              inactiveColor: widget.inactiveColor ?? color.withOpacity(0.3),
              onChanged: (value) {
                final duration = _duration;
                if (duration == null) {
                  return;
                }
                final position = value * duration.inMilliseconds;
                player.seek(Duration(milliseconds: position.round()));
              },
              value: (_position != null &&
                      _duration != null &&
                      _position!.inMilliseconds > 0 &&
                      _position!.inMilliseconds < _duration!.inMilliseconds)
                  ? _position!.inMilliseconds / _duration!.inMilliseconds
                  : 0.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _positionText,
                  style: widget.textStyle ?? const TextStyle(fontSize: 16),
                ),
                Text(
                  _remainingText,
                  style: widget.textStyle ?? const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const Key('rewind_button'),
                style: widget.positionButtonStyle,
                onPressed: _backward,
                iconSize: widget.positionIconSize ?? 24,
                icon: Icon(widget.rewindIcon ?? Icons.fast_rewind),
                color: color,
              ),
              const SizedBox(width: 32),
              if (_isPlaying)
                IconButton(
                  key: const Key('pause_button'),
                  style: widget.playButtonStyle,
                  onPressed: _pause,
                  iconSize: widget.playIconSize ?? 48,
                  icon: Icon(widget.pauseIcon ?? Icons.pause),
                  color: color,
                )
              else
                IconButton(
                  key: const Key('play_button'),
                  style: widget.playButtonStyle,
                  onPressed: _play,
                  iconSize: widget.playIconSize ?? 48,
                  icon: Icon(widget.playIcon ?? Icons.play_arrow),
                  color: color,
                ),
              const SizedBox(width: 32),
              IconButton(
                key: const Key('forward_button'),
                style: widget.positionButtonStyle,
                onPressed: _forward,
                iconSize: widget.positionIconSize ?? 24,
                icon: Icon(widget.forwardIcon ?? Icons.fast_forward),
                color: color,
              ),
            ],
          ),
          Center(
            child: DropdownButton<double>(
              underline: const SizedBox(),
              value: player.playbackRate,
              items: rates
                  .map(
                    (rate) => DropdownMenuItem<double>(
                      value: rate,
                      child: Text(
                        '${rate}x',
                        style:
                            widget.textStyle ?? const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (rate) {
                if (rate != null) {
                  player.setPlaybackRate(rate);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  /// Play
  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  /// Pause
  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  /// Stop
  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }

  /// 15 seconds forward
  Future<void> _forward() async {
    final position = _position! + const Duration(seconds: 15);
    await player.seek(position);
    setState(() => _position = position);
  }

  /// 15 seconds backward
  Future<void> _backward() async {
    final position = _position! - const Duration(seconds: 15);
    await player.seek(position);
    setState(() => _position = position);
  }

  /// 2x speed
  Future<void> _speedUp() async {
    await player.setPlaybackRate(2);
  }
}
