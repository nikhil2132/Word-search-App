import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_search/bloc/crossword_bloc.dart';
import 'package:word_search/bloc/crossword_event.dart';
import 'package:word_search/bloc/crossword_state.dart';
import 'package:word_search/position.dart';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({super.key});

  @override
  CrosswordScreenState createState() => CrosswordScreenState();
}

class CrosswordScreenState extends State<CrosswordScreen> {
  final _rowsController = TextEditingController();
  final _colsController = TextEditingController();
  final _wordController = TextEditingController();
  final _bloc = CrosswordBloc(AudioPlayer());
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    _rowsController.dispose();
    _colsController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  void _initializeGrid() {
    final rows = int.parse(_rowsController.text);
    final cols = int.parse(_colsController.text);
    _bloc.add(InitializeGrid(rows, cols));
    Navigator.of(context).pop();
  }

  void _searchWord() {
    final word = _wordController.text;
    _bloc.add(SearchWord(word));
  }

  void _clearSearch() {
    _wordController.clear();
    _bloc.add(const SearchWord(''));
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 4,
          title: const Text(
            'Word Search App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        drawer: _drawer(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  _textField(),
                  _cancelButton(),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<CrosswordBloc, CrosswordState>(
                  bloc: _bloc,
                  builder: (context, state) {
                    if (state.wordFound) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      });
                    }

                    if (state.grid.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No grid available. Please create a grid.'),
                            Text('For creating Grid open Drawer menu '),
                          ],
                        ),
                      );
                    }

                    final rows = state.grid.length;
                    final cols = state.grid[0].length;

                    return grids(cols, rows, state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GridView grids(int cols, int rows, CrosswordState state) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
      ),
      itemCount: rows * cols,
      itemBuilder: (context, index) {
        final row = index ~/ cols;
        final col = index % cols;
        final cellValue = state.grid[row][col];
        final isMatched = state.matches.contains(Position(row, col));

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                String letter = '';
                return _alertDialog(letter, context, row, col);
              },
            );
          },
          child: GridTile(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isMatched
                    ? Colors.green.shade700
                    : Colors.lightBlue.shade300,
              ),
              margin: const EdgeInsets.all(1),
              child: Center(
                child: Text(
                  cellValue,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AlertDialog _alertDialog(
      String letter, BuildContext context, int row, int col) {
    return AlertDialog(
      title: const Text('Enter Letter'),
      content: TextField(
        keyboardType: TextInputType.text,
        onChanged: (value) {
          letter = value.toUpperCase();
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            _bloc.add(UpdateCell(row, col, letter));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  MaterialButton _cancelButton() {
    return MaterialButton(
      onPressed: _clearSearch,
      child: const Text(
        'Cancel',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Expanded _textField() {
    return Expanded(
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 4,
        shadowColor: Colors.grey,
        child: TextField(
          controller: _wordController,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                  onPressed: _searchWord,
                  icon: const Icon(
                    Icons.search,
                  )),
            ),
            hintText: 'Search',
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) => _searchWord(),
        ),
      ),
    );
  }

  Drawer _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightBlue[300],
            ),
            child: const Text('Settings'),
          ),
          ListTile(
            title: TextField(
              controller: _rowsController,
              decoration: const InputDecoration(labelText: 'Rows'),
              keyboardType: TextInputType.number,
            ),
          ),
          ListTile(
            title: TextField(
              controller: _colsController,
              decoration: const InputDecoration(labelText: 'Columns'),
              keyboardType: TextInputType.number,
            ),
          ),
          ListTile(
            title: MaterialButton(
              elevation: 0,
              color: Colors.lightBlue[300],
              onPressed: _initializeGrid,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                child: Text(
                  'Create Grid',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
