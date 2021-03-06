import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Edit extends StatefulWidget {
  final value;
  final value2;
  final topic;

  Edit({
    Key key,
    @required this.value,
    @required this.topic,
    this.value2,
  }) : super(key: key);
  @override
  _EditState createState() =>
      _EditState(value: value, topic: topic, value2: value2);
}

class _EditState extends State<Edit> {
  _EditState({
    @required this.value,
    @required this.topic,
    this.value2,
  }) : super();
  final topic;
  final value;
  final value2;
  var isUser;
  TextEditingController _topicController = TextEditingController();
  TextEditingController _isUserController = TextEditingController();

  getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var topic = preferences.getString(widget.value);
    var topic2 = preferences.getString(widget.value2);
    isUser = value2;

    setState(() {
      _topicController.text = topic;
      _isUserController.text = topic2;
    });

    print(isUser);
  }

  saveData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(widget.value, _topicController.text);
    await preferences.setString(widget.value2, _isUserController.text);
    _topicController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
    print(widget.value);
    print(widget.value2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Panel'),
        backgroundColor: Colors.blue,
      ),
      body: Builder(builder: (context) {
        return Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextFormField(
                controller: _topicController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Topic ' + topic,
                    contentPadding: EdgeInsets.only(left: 10.0)),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                  child: isUser == null ? null : _buildText(_isUserController)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        saveData();
                        _displaySnackBar(context);
                        FocusScope.of(context).unfocus();
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(fontSize: 16),
                      ),
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                  )
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}

Widget _buildText(TextEditingController controller) {
  return Column(
    children: [
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Topic Tekanan Darah (Diastole)',
            contentPadding: EdgeInsets.only(left: 10.0)),
      ),
      SizedBox(
        height: 20.0,
      )
    ],
  );
}

_displaySnackBar(BuildContext context) {
  final snackBar = SnackBar(content: Text('Berhasil Disimpan'));
  Scaffold.of(context).showSnackBar(snackBar);
}
