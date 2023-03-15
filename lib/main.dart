import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white24),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var generatedList=<WordPair>[];
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair wordPair){
    favorites.remove(wordPair);
    notifyListeners();
  }

  void getNext() {
    generatedList.add(current);
    current = WordPair.random();
    notifyListeners();
  }

  void clear(){
    generatedList=[];
    favorites=[];
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context,constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}



class FavoritePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Choose your favorites'),
      );
    }

    var  favoriteCards = appState.favorites.map((x) =>Expanded(
      child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          ListTile (
                  leading: IconButton(icon: Icon(Icons.do_disturb),onPressed: () {
                    appState.removeFavorite(x);
                  }),
                  title: Text(x.asString)),
        ],
      ),
    )).partition(2)
        .map((e) => Row(children: e));

    return ListView(children:[
      Padding(
        padding: const EdgeInsets.all(20),
        child: Text('You have '
            '${appState.favorites.length} favorites:'),
      ),...favoriteCards
    ]);
  }
}

class GeneratedList extends StatelessWidget {
  List<WordPair> generatedList;
  List<WordPair> favorites;
  static const limit = 20;
  WordPair emptyWordPair = WordPair(" "," ");

  GeneratedList(this.generatedList,this.favorites);

  List<WordPair> getList(){
    if(generatedList.length<limit){
      List<WordPair> subList =[];
      subList.addAll(List.filled(limit-generatedList.length,emptyWordPair));
      subList.addAll(generatedList.sublist(0,min(limit, generatedList.length)));
      return subList;
    }else{
      return generatedList.sublist(generatedList.length-limit,generatedList.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    var subFavorite=getList().asMap().entries
    .map((entry) {
      var index = entry.key;
      var e = entry.value;
      var transparent = Color(0xFF0E3311).withOpacity(min(1, index/10));
      var text = Text("${e.first}${e.second}", style: TextStyle(color:transparent,fontSize: 16));
      return Container(
        alignment: Alignment.center,
        height: 25.0,
        child: Center(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children:favorites.contains(e) ?[Icon(Icons.favorite,color: transparent),SizedBox(width: 5),text] : [text]),
          ),
      );
    }).toList();
    return ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: subFavorite);
  }
}

class GeneratorPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GeneratedList(appState.generatedList,appState.favorites),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),

              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.clear();
                },
                child: Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pair.first.toLowerCase(),
              style: style,
              semanticsLabel: "${pair.first}",
            ),Text(
              pair.second.capitalize(),
              style: style.merge(TextStyle(fontWeight: FontWeight.bold)),
              semanticsLabel: "${pair.second}",
            ),
          ],
        ),
      ),
    );
  }
}

extension Partition<T> on Iterable<T>{
  Iterable<List<T>> partition(int partitionNum){
    var es=toList();
    var chunks = <List<T>>[];
    for (var i = 0; i < es.length; i += partitionNum) {
      chunks.add(es.sublist(i, i+partitionNum > es.length ? es.length : i + partitionNum));
    }
    return chunks;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}