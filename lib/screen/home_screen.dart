import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vid_player/component/custom_video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? video; //-- XFile은 Image_Picker에서 제공해주는 '파일의 클래스'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: video == null ? renderEmpty() : renderVideo(),
    );
  }

  Widget renderVideo() {
    return Center(
      child: CustomVideoPlayer(
        video: video!,
        onNewVideoPressed: onNewVideoPressed,
      ),
    );
  }

  Widget renderEmpty() {
    return Container(
      width: MediaQuery.of(context).size.width, //-- 원래 StatelessWidget 안에있을때 build 안에 포함되어있던 코드였는데,
      //-- build 밖으로 따로 빼주고 HomeScreen을 StatefulWidget으로 변경해주면 context를 어디서든, 어느 함수에서든 context를 가져올 수 있다고한다.
      decoration: getBoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Logo(
            onTap: onNewVideoPressed,
          ),
          SizedBox(height: 30.0), //-- padding 대신 유용하게 사용하는 팁. padding을 사용하면 감싸주는 형태로 코드가 더 많아지니까.
          _AppName(),
        ],
      ),
    );
  }

  void onNewVideoPressed() async { //-- ImagePicker를 통해 갤러리로 이동해서 사용자가 파일을 고를때까지 기다려야 하기 때문에 async
    final video = await ImagePicker().pickVideo(
      source: ImageSource.gallery, //-- ImageSource. 까지만 입력하면 여러가지 기능 확인 가능. pickVideo 안에 gallery는 말그대로 갤러리를 열어서 비디오를 고르게끔 하는 기능
      //-- ImageSource.camera 를 입력하면 갤러리를 열지 않고 촬영모드 실행
      //-- 여기까지 구현하고 저장 후 실제 로고를 눌러 기능을 실행했을때 "MissingPluginException" 에러가 발생할 수도 있음. 이유는 플러그인을 제대로 설치않아서.
      //--이때 터미널에서 "flutter clean" 실행 > 앱 종료 > 다시실행
    );

    if (video != null) { //-- 위 코드를 통해 비디오가 선택되면 video변수에 관련 정보가 저장되고, setState를 통해 정보 사용 준비 완료
      setState(() {
        this.video = video;
      });
    }
  }

  BoxDecoration getBoxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient( // -- 가운데부터 동그랗게 퍼지는 그래디언트를 쓰려면 RadialGradient를 사용
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2A3A7C),
          Color(0xFF000118),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final VoidCallback onTap;

  const _Logo({
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector( //-- GestureDetecor : 로고 이미지 눌렀다는 제스쳐에 대한 기능을 지정할 수 있는 위젯
      onTap: onTap,
      child: Image.asset(
        'asset/image/logo.png',
      ),
    );
  }
}

class _AppName extends StatelessWidget {
  const _AppName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30.0,
      fontWeight: FontWeight.w300,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'VIDEO',
          style: textStyle,
        ),
        Text(
          'PLAYER',
          style: textStyle.copyWith( //-- 위에 선언한 textStyle을 그대로 복사하여 새로 설정한 파라미터로 덮어쓰기하고자 할때 copyWith 사용
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
