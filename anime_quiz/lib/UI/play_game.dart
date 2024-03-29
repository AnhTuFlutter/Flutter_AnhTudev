import 'package:anime_quiz/UI/bonus_coins.dart';
import 'package:anime_quiz/entitys/question.dart';
import 'package:anime_quiz/entitys/user.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:anime_quiz/controller/play_game_controller.dart';
import 'package:anime_quiz/entitys/traloi.dart';
import 'package:anime_quiz/controller/controller.dart';
import 'package:anime_quiz/controller/audio_controller.dart';

class Play_Game extends StatefulWidget {
  final List<Question> questionList;
  final int index;
  final User user;
  const Play_Game({Key key, this.questionList, this.index, this.user})
      : super(key: key);

  @override
  _Play_GameState createState() => _Play_GameState(questionList, index, user);
}

class _Play_GameState extends State<Play_Game> {

  List<Question> questionList;
  int index;
  User user;

  AudioController audioController = new AudioController();
  Question question = new Question();
  Play_Game_Controller play_game_controller = new Play_Game_Controller();
  Controller controller = new Controller();
  List<String> listDapAn = new List<String>();
  List<String> listDapAnDaTron = new List<String>();
  List<TraLoi> luuTraLoi = new List<TraLoi>();
  List<bool> anHienOChon = [
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];

  //Contructer
  _Play_GameState(this.questionList, this.index, this.user) {
    question = questionList[index];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioController.sourceNewLevel();
    luuTraLoi = play_game_controller.khoiTaoLuuTraLoi(question.dapan);
    listDapAn = play_game_controller.tachChuoi(question.dapan);
    listDapAnDaTron = play_game_controller.tronDapAn(listDapAn);
  }
  _troGiup(){
    if(user.coin > 0){
      controller.truCoin(user);
      if(luuTraLoi[0].chuCai == ''){
        luuTraLoi[0].chuCai = listDapAn[0];
        luuTraLoi[0].viTriDien = 0;
        for (var i = 0; i < listDapAnDaTron.length; i++) {
          if(luuTraLoi[0].chuCai == listDapAnDaTron[i]){
            luuTraLoi[0].viTriChon = i;
            anHienOChon[i] = false;
            break;
          }
        }
        setState(() {
          
        });
        return;
      }else{
        for (var i = 1; i < luuTraLoi.length; i++) {
          if(luuTraLoi[i].chuCai == '' && luuTraLoi[i-1].chuCai != ''){
            luuTraLoi[i].chuCai = listDapAn[i];
            luuTraLoi[i].viTriDien = i;
            for (var j = 0; j < listDapAnDaTron.length; j++) {
              if(luuTraLoi[i].chuCai.compareTo(listDapAnDaTron[j]) == 0){
                if(anHienOChon[j] == true){
                  luuTraLoi[i].viTriChon = j;
                  anHienOChon[j] = false;
                  break;
                }
              }
            }
            break;
          }
        }
        setState(() {
          
        });
        if (kiemtraketqua() == true) {
          controller.updateQuestion(question);
          controller.congCoin(user);
          audioController.sourceWin();
          thongbaowin(context);
        }
      }
    }
    
  }
  _nextLevel() {
    Navigator.pop(context);
    //Navigator.of(context).pop();
    setState(() {
      index++;
      question = questionList[index];
      luuTraLoi = play_game_controller.khoiTaoLuuTraLoi(question.dapan);
      listDapAn = play_game_controller.tachChuoi(question.dapan);
      listDapAnDaTron = play_game_controller.tronDapAn(listDapAn);
      anHienOChon = [
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true
      ];
    });
  }

  _pushBonus() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Bonus_Coins()));
  }

  _pushLevel() {
    Navigator.pop(context);
  }

  xuLyChonChucai(String chucai, int vitrichon) {
    int dem = 0;
    int demNhapHetO = 0;
    for (var j = 0; j < luuTraLoi.length; j++) {
      if (luuTraLoi[j].chuCai == '') {
        dem++;
      }
    }
    if (dem != 0) {
      for (var i = 0; i < luuTraLoi.length; i++) {
        if (luuTraLoi[i].chuCai == '') {
          audioController.sourceChonO();
          setState(() {
            anHienOChon[vitrichon] = false;
            luuTraLoi[i].chuCai = chucai;
            luuTraLoi[i].viTriChon = vitrichon;
            luuTraLoi[i].viTriDien = i;
          });
          break;
        }
      }
      for (var j = 0; j < luuTraLoi.length; j++) {
        if (luuTraLoi[j].chuCai == '') {
          demNhapHetO++;
        }
      }
    }
    // Kiem tra va update du lieu DB
    if (demNhapHetO == 0) {
      print(kiemtraketqua());
      if (kiemtraketqua() == true) {
        controller.updateQuestion(question);
        controller.congCoin(user);
        audioController.sourceWin();
        thongbaowin(context);
      } else {
        audioController.sourceSai();
      }
    }
  }

  xuLyTraLaiChuCai(String chuCaiTra, int viTriTra) {
    if (chuCaiTra != '') {
      audioController.sourceTraO();
      setState(() {
        anHienOChon[luuTraLoi[viTriTra].viTriChon] = true;
        luuTraLoi[viTriTra].chuCai = '';
        luuTraLoi[viTriTra].viTriChon = null;
        luuTraLoi[viTriTra].viTriDien = null;
      });
    }
  }

  bool kiemtraketqua() {
    int tam = 0;
    for (var i = 0; i < luuTraLoi.length; i++) {
      if (luuTraLoi[i].chuCai.compareTo(listDapAn[i]) == 0) {
        tam++;
      }
    }
    return tam == luuTraLoi.length ? true : false;
  }

  thongbaowin(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return showDialog(
        context: context,
        barrierDismissible: false,
        child: new SimpleDialog(
          backgroundColor: Colors.lightGreen[100],
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          title: new Text(
            'You Win',
            style: TextStyle(
              fontSize: 60.0,
              color: Colors.yellow[900],
            ),
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: size.height/3,
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: new Image.asset(
                      "assets/imagesGame/${question.linkimage}",  
                      fit: BoxFit.contain),
                ),
                Container(
                  child: Text(
                    question.dapan,
                    style:
                        TextStyle(fontSize: 40.0, color: Colors.lightBlue[900]),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    OutlineButton(
                      onPressed: () {},
                      child: Row(
                        children: <Widget>[
                          Text(
                            '+',
                            style: TextStyle(
                              fontSize: 50.0,
                              color: Colors.yellow[900],
                            ),
                          ),
                          Image.asset(
                            'assets/images/coin.png',
                            height: 40.0,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                      highlightElevation: 5.0,
                      borderSide: BorderSide(
                        width: 3.0,
                        color: Colors.blue[300],
                      ),
                    ),
                    OutlineButton(
                      onPressed: () {
                        _nextLevel();
                      },
                      child: Icon(
                        Icons.play_arrow,
                        size: 50.0,
                        color: Colors.redAccent,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                      highlightElevation: 5.0,
                      borderSide: BorderSide(
                        width: 3.0,
                        color: Colors.red[200],
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      //title: "Nguyen Anh Tu",
      home: new Scaffold(
          // drawer: Drawer(
          //   child: Row(
          //     children: <Widget>[],
          //   ),
          // ),
          appBar: new AppBar(
            backgroundColor: Colors.green,
            automaticallyImplyLeading: true,
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 20.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 15.0),
                      child: RaisedButton(
                        child: Text(
                          'Level: ${index + 1}',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                        color: Colors.pink,
                        elevation: 4.0,
                        splashColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        onPressed: () {
                          _pushLevel();
                        },
                      ),
                    ),
                    Container(
                      child: RaisedButton(
                        child: Wrap(
                          spacing: 5.0,
                          children: <Widget>[
                            Text(
                              '${user.coin}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            Image.asset(
                              'assets/images/coin.png',
                              height: 23.0,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        color: Colors.blueAccent,
                        elevation: 4.0,
                        splashColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        onPressed: () {
                          _pushBonus();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: new Material(
            child: Container(
              constraints: BoxConstraints.expand(),
              color: Colors.yellow[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      "Character's name ??",
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                  Container(
                    height: size.height / 2,
                    width: size.width,
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      border: Border.all(
                        width: 5.0,
                        color: Colors.yellow,
                      ),
                    ),
                    child: new Image.asset(
                      "assets/imagesGame/${question.linkimage}",
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    //height: 50,
                    //color: Colors.deepOrange,
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: 5.0,
                      children: <Widget>[
                        for (var i = 0; i < question.dapan.length; i++)
                          Container(
                            width: 40.0,
                            child: RaisedButton(
                              padding: EdgeInsets.only(left: 0, right: 0),
                              child: Text(
                                //--------------------------------------------------------------------------- Noi Tra Loi
                                luuTraLoi[i].chuCai,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25.0),
                              ),
                              color: Colors.deepOrange,
                              splashColor: Colors.white,
                              onPressed: () {
                                xuLyTraLaiChuCai(luuTraLoi[i].chuCai, i);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 400,
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: RaisedButton(
                            child: Wrap(
                              children: <Widget>[
                                Icon(Icons.account_circle, color: Colors.amber),
                                Text(
                                  'Friends',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                )
                              ],
                            ),
                            color: Colors.purple,
                            splashColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0))),
                            onPressed: () {},
                          ),
                        ),
                        Container(
                          child: RaisedButton(
                            child: Wrap(
                              children: <Widget>[
                                Icon(Icons.lightbulb_outline, color: Colors.tealAccent),
                                Text(
                                  'Hints',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                )
                              ],
                            ),
                            color: Colors.blue,
                            splashColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0))),
                            onPressed: () {_troGiup();},
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            for (var i = 0; i < 9; i++)
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: 40.0,
                                  minWidth: 30.0,
                                ),
                                alignment: Alignment.center,
                                child: Visibility(
                                  visible: anHienOChon[i],
                                  child: RaisedButton(
                                    padding: EdgeInsets.only(left: 0, right: 0),
                                    child: Text(
                                      listDapAnDaTron[i],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30.0),
                                    ),
                                    color: Colors.green,
                                    splashColor: Colors.white,
                                    onPressed: () {
                                      xuLyChonChucai(listDapAnDaTron[i], i);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            for (var i = 9; i < 18; i++)
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: 40.0,
                                  minWidth: 30.0,
                                ),
                                alignment: Alignment.center,
                                child: Visibility(
                                  visible: anHienOChon[i],
                                  child: RaisedButton(
                                    padding: EdgeInsets.only(left: 0, right: 0),
                                    child: Text(
                                      listDapAnDaTron[i],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30.0),
                                    ),
                                    color: Colors.green,
                                    splashColor: Colors.white,
                                    onPressed: () {
                                      xuLyChonChucai(listDapAnDaTron[i], i);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
