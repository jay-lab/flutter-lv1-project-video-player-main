import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final VoidCallback onNewVideoPressed;

  const CustomVideoPlayer({
    required this.video,
    required this.onNewVideoPressed,
    Key? key,
  }) : super(key: key);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController; //-- video_player 라는 플러그인을 설치했기때문에 사용할 수 있는 클래스
  Duration currentPosition = Duration();
  bool showControls = false;

  @override
  void initState() { //-- 위의 'VideoPlayerController'를 언제 새로 생성할 것이냐에 대해 고민했을 때, 처음 한번만 생성되면 되기때문에 initState를 사용하게 되었고 그 결과
    //-- initializeController 안에서 videoController를 사용하고있다.
    super.initState();

    initializeController(); //-- 참고로 initState가 initializeController가 끝날때까지 기다리지는 않고 실행만 한다.
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget){ //-- 이 내용 중요. (New 버튼 눌렀을때에 대한 대응 로직)
    //-- New Video 버튼을 눌러 새로운 동영상을 선택하면 화면을 새 영상으로 갱신하는 로직 'initializeController'(아래에 구현해둔)을 실행해야할 필요가 있는데
    //-- initState에 설정된 initializeController() 만으로 갱신되지 않는 이유는 initState는 처음 한번만 실행되는 StatefulWidget의 특성때문.
    //-- 따라서 state가 살아있는 상태에서 위젯의 파라미터만 변경될때 실행되는 "didUpdateWidget"를 활용하여 initializeController()를 실행하도록 구현
    super.didUpdateWidget(oldWidget);

    if(oldWidget.video.path != widget.video.path){
      initializeController();
    }
  }

  initializeController() async {
    currentPosition = Duration(); //-- 이 코드는 새로운 영상으로 갱신 했을때 currentPosition값이 싱크가 안맞아서 발생되는 에러에 대응하기 위한 코드(currentPosition 리셋 역할)

    videoController = VideoPlayerController.file( //-- VideoPlayerConroller.asset을 하게 되면 프로젝트 안에있는 폴더에 있는 파일을 레퍼런스하여 쓸 수 있는데
      //-- 여기서는 ".file"로 하였다. ".networkk"를 하게되면 url을 통해 스트리밍 기능도 가능.
      File(widget.video.path), //-- 여기서 참고해야할 내용은, 위에서 받아주고 있는 XFile 타입과 여기있는 File 타입은 조금 다르다.
      //-- 여기있는 File 타입은 실제 플러터 프레임워크에서 사용하고있는 파일타입.
      //-- 위에있는 XFile 타입은 image_picker에서 사용하고있는 파일타입.
      //-- 따라서 위에서 넘겨받은 XFile 타입을, 플러터에서 사용하는 파일타입으로 변환해주어야한다. 여기있는 File타입을 import할때 "dart.io"에 속한것으로 import한 후 XFile에 설정된 비디오파일의 위치만 File의 파라미터로 넘겨주면 된다.
      //-- 좀더 설명하자면, 앞단에서는 image_picker라는 플러그인을 통해 갤러리에서 동영상을 선택할수 있었다(image_picker의 역할)
      //-- 이렇게 image_picker를 통해 선택된 파일의 타입은 Xfile타입(image_picker 플러그인 전용 타입)
      //-- 이 후, Video_Player 플러그인을 통해 비디오를 제어하기 위해서는 '플러터 전용 파일 타입' 이어야하니까 widget.video 파일을 File()로 감싸서 타입캐스팅.
      //-- 플러터 공식 파일타입으로 인식된 파일의 경로를 가지고  VideoPlayerController.file()를 통해 동영상 제어
    );

    await videoController!.initialize(); //-- 초기화. 즉 앞 화면에서 넘겨져온 파일정보를 가지고 위의 단계에서 파일의 경로 정보를 통해 플러터 파일 타입으로 초기화. 이것이 완료될때까지 await.
    //-- await를 사용하기 위해 이를 감싸고있는 initializeController 함수에 async 사용

    videoController!.addListener(() { //-- 슬라이더를 구현하는 단계에서, 영상이 실행되면 그 만클 슬라이더도 움직여줘야하는데 무반응. 슬라이더를 조절해도 영상 재생 위치 무반응
      //-- 따라서 동영상이 실행되면 동영상의 값(예를들면 포지션의 값)이 변하기 때문에 이것을 캐치하기 위해 addListener 사용
      final currentPosition = videoController!.value.position; //-- 그런데 문제는 이렇게만 했다고해서 슬라이더를 움직이는거로 영상의 위치를 변경할 수 없다.

      setState(() { //-- videoController가 새로 설정되면 새로 build 되도록 setState 사용
        this.currentPosition = currentPosition;
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) { //-- initState 단계에서 initializeController()가 끝날때까지 기다리지 않기 때문에 videoController는 아직 null일 수 있다. 이에 대한 대응 코드
      return CircularProgressIndicator(); //-- 로딩바 실행
    }

    return AspectRatio( //-- 화면에 표시되는 영상의 비율을 지켜주는 방법
      aspectRatio: videoController!.value.aspectRatio, //-- 화면에 표시되는 영상의 비율을 지켜주는 방법
      child: GestureDetector(
        onTap: (){
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack( //-- 영상 위에 버튼을 띄워주기 위한 Stack 위젯 사용. VideoPlayer만 있는 상태에서 'Option+Enter' 키 입력 > Wrap With Column 선택(파라미터 형태가 똑같으니까) > Column을 Stack으로 변경
          children: [
            VideoPlayer( //-- 영상을 표시해주는 위젯(플러그인에서 지원하는 위젯)
              videoController!,
            ),
            if (showControls)
              _Controls(
                onReversePressed: onReversePressed,
                onPlayPressed: onPlayPressed,
                onForwardPressed: onForwardPressed,
                isPlaying: videoController!.value.isPlaying,
              ),
            if (showControls)
              _NewVideo(
                onPressed: widget.onNewVideoPressed,
              ),
            _SliderBottom(
              currentPosition: currentPosition,
              maxPosition: videoController!.value.duration,
              onSliderChanged: onSliderChanged,
            ),
          ],
        ),
      ),
    );
  }

  void onSliderChanged(double val) {
    videoController!.seekTo(
      Duration(
        seconds: val.toInt(),
      ),
    );
  }

  void onReversePressed() {
    final currentPosition = videoController!.value.position;

    Duration position = Duration();

    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onForwardPressed() {
    final maxPosition = videoController!.value.duration; //-- 영상의 전체길이
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;

    if ((maxPosition - Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position); //-- 영상 재생 위치 설정(변경)
  }

  void onPlayPressed() {
    //-- 이미 실행중이면 중지
    //-- 실행중이 아니면 실행
    // setState(() { //-- 이 setState 아니면 재생 & 중지 반응이 없음. 그 이유는 아래 renderIconButton 버튼 안에서 사용된 "isPlaying" 값이 build된 이후로 계속 하나의 값이기때문에. 즉 갱신되지 않은 값으로 머물러있기때문.
      //-- 이를 해결하기 위해 setState를 통해 새로 빌드
      //-- 인줄 알았으나.. 왜 setState를 지워도 정상적으로 동작하는거지?? 강의 내용과 다른데
    print('test2 : ');
    print(videoController!.value.isPlaying);
    if (videoController!.value.isPlaying) { //-- isPlaying : 실행중인지 아닌지 알 수 있는 속성
      videoController!.pause();
    } else {
      videoController!.play();
    }
    // });
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;

  const _Controls({
    required this.onPlayPressed,
    required this.onReversePressed,
    required this.onForwardPressed,
    required this.isPlaying,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5), //-- 투명도 설정
      height: MediaQuery.of(context).size.height, //-- 이 설정을 하지않으면 버튼만클릭했을때 뿐만 아니라 버튼과 동일한 세로 선상을 눌러도 이벤트가 발생되는 현상
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        //-- "Column과 Row 모두 기본 crossAxisAlignment는 center". 그럼 위 코드를 통해 세로 사이즈를 최대로 늘리면 자연스레 버튼들도 영상의 가운데로 위치하게 될텐데 문제는
        //-- 버튼만 클릭했을때 뿐만 아니라 버튼과 동일한 세로 선상을 눌러도 이벤트가 발생되는 현상. 그래서
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton( //-- rederIconButton : 밑에 임의로 만든 '위젯'
            onPressed: onReversePressed,
            iconData: Icons.rotate_left,
          ),
          renderIconButton(
            onPressed: onPlayPressed,
            iconData: isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          renderIconButton(
            onPressed: onForwardPressed,
            iconData: Icons.rotate_right,
          ),
        ],
      ),
    );
  }

  Widget renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 30.0,
      color: Colors.white,
      icon: Icon(
        iconData,
      ),
    );
  }
}

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewVideo({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned( //-- Stack 위젯 안에서 많이 쓰는 방법으로써 하위 위젯을 특정 위치에 배치하기 위해 사용하는 위젯
      right: 0, //-- 그래서 오른쪽 0픽셀만큼 이동된 위치 즉, 오른족 끝에 위치
      child: IconButton(
        onPressed: onPressed,
        color: Colors.white,
        iconSize: 30.0,
        icon: Icon(
          Icons.photo_camera_back,
        ),
      ),
    );
  }
}

class _SliderBottom extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _SliderBottom({
    required this.currentPosition,
    required this.maxPosition,
    required this.onSliderChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0, //-- 슬라이더를 아래로 내리고, 왼쪽부터 오른쪽 끝까지 당기도록 하는 설정
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
              '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}', //-- String 와야할 자리에 int로 그대로 출력하면 에러
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Slider(
                value: currentPosition.inSeconds.toDouble(),
                onChanged: onSliderChanged,
                max: maxPosition.inSeconds.toDouble(),
                min: 0,
              ),
            ),
            Text(
              '${maxPosition.inMinutes}:${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
