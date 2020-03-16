import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeData>(
        builder: (_, theme) {
          return MaterialApp(
            title: 'My Bloc',
            home: BlocProvider(
              create: (_) => HomeBloc(),
              child: HomePage(),
            ),
            theme: theme,
          );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  List colors = [
    Colors.white,
    Colors.lightGreen[200],
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.blue[300],
    Colors.pink[200]
  ];

  _getToggleBoxDecoration(index) {
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloc'),
      ),
      body: BlocBuilder<HomeBloc, int>(
        builder: (_, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: RaisedButton(
                  child: Text('Hello'),
                  color: _getToggleBoxDecoration(index),
                  onPressed: () =>
                      context.bloc<HomeBloc>().add(HomeEvent.toggleColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: RaisedButton(
                  color: Colors.blue[200],
                  child: Text('Press me'),
                  onPressed: () =>
                      context.bloc<ThemeBloc>().add(ThemeEvent.toggle),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(_createRoute());
                }),
          ),
        ],
      ),
    );
  }
}

enum HomeEvent { toggleColor }

class HomeBloc extends Bloc<HomeEvent, int> {
  Random random = new Random();

  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(HomeEvent event) async* {
    switch (event) {
      case HomeEvent.toggleColor:
        yield random.nextInt(7);
        break;
    }
  }
}

Route _createRoute() {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SecondPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      });
}

class SecondPage extends StatefulWidget {
  SecondPage({Key key}) : super(key: key);

  @override
  _SecondPageWidgetState createState() => _SecondPageWidgetState();
}

class _SecondPageWidgetState extends State<SecondPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _getSelectedItem() {
    if (_selectedIndex == 0) {
      return new MyListStatelessWidget();
    } else {
      return new MyImageStatelessWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Center(
        child: _getSelectedItem(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('List'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            title: Text('Image'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyListStatelessWidget extends StatelessWidget {
  final List<String> items = List<String>.generate(100, (i) => "Message $i");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              ListTile(title: Text('${items[index]}')),
              Divider()
            ],
          );
        },
      ),
    );
  }
}

class MyImageStatelessWidget extends StatelessWidget {
  static var assetsImage = new AssetImage('assets/cat_1.jpg');
  static var image = new Image(image: assetsImage, fit: BoxFit.cover);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(child: image),
      ),
    );
  }
}

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  @override
  ThemeData get initialState => ThemeData.light();

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    switch (event) {
      case ThemeEvent.toggle:
        yield state == ThemeData.dark() ? ThemeData.light() : ThemeData.dark();
        break;
    }
  }
}
