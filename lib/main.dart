import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final list = <Question<dynamic>>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list.add(TitleQuestion(id: '2', title: 'Section title'));
    list.add(InputQuestion(
        id: '1',
        hint: 'Please write you answer here.',
        title:
        'Breaking: Changed resourcePrefix to maplibre_ from mapbox_ 647 and renamed resources accordingly. Note that this is a breaking change since the names of public resources were renamed as well. Replaced Mapbox logo with MapLibre logo.'));

    list.add(ImageQuestion(
        id: '2',
        value: [],
        title:
        'GMS location: Replace new LocationRequest() with LocationRequest.Builder, and LocationRequest.PRIORITY_X with Priority.PRIORITY_X'));
    list.add(VideoQuestion(
        id: '3',
        title:
        'Increment minSdkVersion from 14 to 21, as it covers 99.2%% of the newer devices since 2014'));
    list.add(MultiSelectionQuestion(
        ['Option1', 'Option2', 'Option3', 'Option4'],
        id: '4', title: 'and lessens the backward compatibility burden (630)'));
    list.add(SingleSelectionQuestion(
        ['Option1', 'Option2', 'Option3', 'Option4'],
        id: '5', title: 'Catches NaN for onMove event (621)'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            var question = list[index];
            switch (question.type) {
              case QuestionType.input:
                return InputWidget(question: question as InputQuestion);
              case QuestionType.image:
                return ImageQuestionWidget(question: question as ImageQuestion);
              case QuestionType.singleSelection:
                return ListTile(title: Text(question.title));
              case QuestionType.multiSelection:
                return ListTile(title: Text(question.title));
              case QuestionType.video:
                return VideoQuestionWidget(question: question as VideoQuestion);
              case QuestionType.audio:
                return Container();
              case QuestionType.title:
                return SectionTitleWidget(question: question as TitleQuestion);
            }
          },
          itemCount: list.length,
          separatorBuilder: (BuildContext context, int index) =>
          const Divider(),
        ),
      ),
    );
  }
}

class VideoQuestionWidget extends StatelessWidget {
  final VideoQuestion question;

  const VideoQuestionWidget({Key? key, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: question,
        builder: (BuildContext context, String? value, Widget? child) {
          var videoPath = value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              QuestionTitleWidget(question: question),
              if (videoPath != null)
                FutureBuilder(
                  future: VideoThumbnail.thumbnailFile(video: videoPath),
                  builder: (context, state) {
                    print(state);
                    if (state.connectionState != ConnectionState.done &&
                        !state.hasData) {
                      return Container();
                    }
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (context, _, __) {
                                      return VideoViewerPage(
                                        video: value!,
                                        thumbnail: state.data!,
                                      );
                                    },
                                    opaque: false));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8)),
                            clipBehavior: Clip.antiAlias,
                            child: Hero(
                                tag: state.data!,
                                child: Image.file(File(state.data!))),
                          ),
                        ),
                        const Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.play_circle,
                                color: Colors.white, size: 40))
                      ],
                    );
                  },
                ),
              OutlinedButton.icon(
                  icon: const Icon(Icons.photo),
                  onPressed: () async {
                    var result = await showModalBottomSheet<XFile>(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        builder: (context) {
                          return const MediaPickerModel(
                            showVideo: true,
                          );
                        });
                    if (result != null) {
                      question.value = result.path;
                    }
                  },
                  label: const Text('Select/Record video'))
            ],
          );
        });
  }
}

class ImageQuestionWidget extends StatelessWidget {
  final ImageQuestion question;

  const ImageQuestionWidget({Key? key, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: question,
        builder: (BuildContext context, List<String> value, Widget? child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              QuestionTitleWidget(question: question),
              SizedBox(
                height: value.isNotEmpty ? 210 : 10.0,
                child: GridView.builder(
                  itemBuilder: (context, index) {
                    var image = value[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (context, _, __) {
                                  return ImageViewerPage(image: image);
                                },
                                opaque: false));
                      },
                      child: Hero(
                        tag: image,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsetsDirectional.only(
                              end: 8, bottom: 8),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)),
                          child: Image.file(
                            File(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: value.length,
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                ),
              ),
              OutlinedButton.icon(
                  icon: const Icon(Icons.photo),
                  onPressed: () async {
                    var result = await showModalBottomSheet<XFile>(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        builder: (context) {
                          return const MediaPickerModel();
                        });
                    if (result != null) {
                      question.add(result.path);
                    }
                  },
                  label: const Text('Select/Capture image'))
            ],
          );
        });
  }
}

class SectionTitleWidget extends StatelessWidget {
  final TitleQuestion question;

  const SectionTitleWidget({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Text(
          question.title,
          style: Theme.of(context).textTheme.titleLarge,
        ));
  }
}

class InputWidget extends StatelessWidget {
  final InputQuestion question;

  const InputWidget({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuestionTitleWidget(question: question),
        TextField(
          decoration: InputDecoration(
              hintText: question.hint,
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              isDense: true),
        )
      ],
    );
  }
}

class QuestionTitleWidget extends StatelessWidget {
  const QuestionTitleWidget({
    super.key,
    required this.question,
  });

  final Question<dynamic> question;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        question.title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

enum QuestionType {
  title,
  input,
  image,
  singleSelection,
  multiSelection,
  video,
  audio
}

abstract class Question<T> extends ValueNotifier<T> {
  final String id;
  final String title;

  final QuestionType type;

  Question(
      {required this.id,
        required this.title,
        required T value,
        required this.type})
      : super(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Question && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Question{id: $id, title: $title, value: $value, type: $type}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
    };
  }
}

class InputQuestion extends Question<String?> {
  final String? hint;

  InputQuestion(
      {required String id, this.hint, required String title, String? value})
      : super(id: id, title: title, value: value, type: QuestionType.input);
}

class VideoQuestion extends Question<String?> {
  VideoQuestion({required String id, required String title, String? value})
      : super(id: id, title: title, value: value, type: QuestionType.video);
}

class TitleQuestion extends Question<String?> {
  TitleQuestion({required String id, required String title, String? value})
      : super(id: id, title: title, value: value, type: QuestionType.title);
}

class SingleSelectionQuestion extends Question<String?> {
  final List<String> items;

  SingleSelectionQuestion(this.items,
      {required String id, required String title, String? value})
      : assert(items.isNotEmpty),
        super(
          id: id,
          title: title,
          value: value,
          type: QuestionType.singleSelection);
}

class MultiSelectionQuestion extends Question<List<String>?> {
  final List<String> items;

  MultiSelectionQuestion(this.items,
      {required String id,
        required String title,
        List<String>? value = const []})
      : assert(items.isNotEmpty),
        super(
          id: id,
          title: title,
          value: value,
          type: QuestionType.multiSelection);
}

class ImageQuestion extends Question<List<String>> {
  final int max;
  final int min;

  ImageQuestion(
      {required String id,
        this.max = 1,
        this.min = 1,
        required String title,
        List<String> value = const []})
      : assert(max >= min),
        super(id: id, title: title, value: value, type: QuestionType.image);

  void add(String newValue) {
    value.add(newValue);
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }
}

class MediaPickerModel extends StatefulWidget {
  final bool showVideo;

  const MediaPickerModel({Key? key, this.showVideo = false}) : super(key: key);

  @override
  State<MediaPickerModel> createState() => _MediaPickerModelState();
}

class _MediaPickerModelState extends State<MediaPickerModel> {
  @override
  Widget build(BuildContext context) {
    var imagePicker = ImagePicker();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Camera/Gallery',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Select either Camera or gallery to Pick/Capture media'),
        ),
        const SizedBox(height: 8),
        if (!widget.showVideo)
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Capture a Picture'),
            onTap: () async {
              try {
                var result =
                await imagePicker.pickImage(source: ImageSource.camera);
                if (mounted) {
                  Navigator.maybePop(context, result);
                }
              } catch (error) {
                print(error);
              }
            },
          ),
        if (widget.showVideo) _divider(),
        if (widget.showVideo)
          ListTile(
            leading: const Icon(Icons.video_camera_back),
            title: const Text('Record a Video'),
            onTap: () async {
              try {
                var result =
                await imagePicker.pickVideo(source: ImageSource.gallery);
                if (mounted) {
                  Navigator.maybePop(context, result);
                }
              } catch (error) {
                print(error);
              }
            },
          ),
        if (!widget.showVideo) _divider(),
        if (!widget.showVideo)
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Select a Picture'),
            onTap: () async {
              try {
                var result =
                await imagePicker.pickImage(source: ImageSource.gallery);
                if (mounted) {
                  Navigator.maybePop(context, result);
                }
              } catch (error) {
                print(error);
              }
            },
          ),
        if (widget.showVideo) _divider(),
        if (widget.showVideo)
          ListTile(
            leading: const Icon(Icons.video_collection),
            title: const Text('Select a Video'),
            onTap: () async {
              try {
                var result =
                await imagePicker.pickVideo(source: ImageSource.gallery);
                if (mounted) {
                  Navigator.maybePop(context, result);
                }
              } catch (error) {
                print(error);
              }
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Divider _divider() => const Divider(height: 0);
}

class ImageViewerPage extends StatelessWidget {
  final String image;

  const ImageViewerPage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Material(
            color: Colors.black45,
            child: GestureDetector(
                onTapDown: (details) {},
                child: Center(
                    child: Hero(tag: image, child: Image.file(File(image)))))));
  }
}

class VideoViewerPage extends StatefulWidget {
  final String video;
  final String thumbnail;

  const VideoViewerPage(
      {Key? key, required this.video, required this.thumbnail})
      : super(key: key);

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  late VideoPlayerController _controller;
  var _videoReady = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.video))
      ..initialize().then((_) {
        Future.delayed(const Duration(milliseconds: 500)).then((_) {
          _videoReady = true;
          _controller
            ..setLooping(true)
            ..play();
          setState(() {});
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Material(
          color: Colors.black45,
          child: GestureDetector(
            onTapDown: (details) {},
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: _videoReady ? 1.0 : 0.0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller)),

                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(playedColor: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                Opacity(
                    opacity: _videoReady ? 0.0 : 1.0,
                    child: Hero(
                      tag: widget.thumbnail,
                      child: Image.file(File(widget.thumbnail)),
                    )),
              ],
            ),
          ),
        ));
  }
}
class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
            color: Colors.black26,
            child: const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
                semanticLabel: 'Play',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}

