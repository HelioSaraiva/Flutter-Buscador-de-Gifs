import 'package:buscadorgifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _image;
  String _search;
  int _offSet = 0;

  Future<Map> _getGif() async {
    http.Response response;
    if(_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=fIKg9AGZCtweq9tdaZNtZoE6ECTRBReQ&limit=20&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=fIKg9AGZCtweq9tdaZNtZoE6ECTRBReQ&q=$_search&limit=19&offset=$_offSet&rating=G&lang=en");
    return json.decode(response.body);
    //json.decode(response.body);
  }

//  @override
//  void initState() {
//    super.initState();
//    _getGif().then((map) {
//      print(map);
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offSet =0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map>(
              future: _getGif(), // a Future<String> or null
              builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return (Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    ));
                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      _image = snapshot.data["data"];
                    return _createGifTable(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int getCont(List dado){
    if(_search == null || _search.isEmpty){
      return dado.length;
    }else{
      return dado.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: getCont(_image),
        itemBuilder: (context, index) {
          if(_search == null || index < _image.length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: _image[index]["images"]["fixed_height"]["url"],
                  height: 300.0,
                  fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>GifPage(snapshot.data["data"][index])));
              },
              onLongPress: (){
                Share.share(_image[index]["images"]["fixed_height"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0,),
                    Text("Carregar mais...", style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0
                    ),)
                  ],
                ),
                onTap: (){
                  setState(() {
                    _offSet += 19;
                  });
                },
              ),
            );
        });
  }
}
