import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_search/position.dart';
import 'crossword_event.dart';
import 'crossword_state.dart';
import 'package:audioplayers/audioplayers.dart';

class CrosswordBloc extends Bloc<CrosswordEvent, CrosswordState> {
  final AudioPlayer audioPlayer;

  CrosswordBloc(this.audioPlayer)
      : super(const CrosswordState(grid: [], matches: [])) {
    on<InitializeGrid>(_onInitializeGrid);
    on<UpdateCell>(_onUpdateCell);
    on<SearchWord>(_onSearchWord);
  }

  void _onInitializeGrid(InitializeGrid event, Emitter<CrosswordState> emit) {
    final grid =
        List.generate(event.rows, (i) => List.generate(event.cols, (j) => ''));
    emit(state.copyWith(grid: grid, matches: []));
  }

  void _onUpdateCell(UpdateCell event, Emitter<CrosswordState> emit) {
    final newGrid = List<List<String>>.from(state.grid);
    newGrid[event.row] = List.from(newGrid[event.row]);
    newGrid[event.row][event.col] = event.letter.toUpperCase();
    emit(state.copyWith(grid: newGrid));
  }

  void _onSearchWord(SearchWord event, Emitter<CrosswordState> emit) {
    final word = event.word.toUpperCase();
    List<Position> matches = [];

    if (word.isEmpty) {
      emit(state.copyWith(message: '', wordFound: false, matches: []));
      return;
    }

    if (_searchHorizontally(word, matches) ||
        _searchVertically(word, matches) ||
        _searchDiagonally(word, matches)) {
      audioPlayer.play(AssetSource('sounds/success.mp3'));
      emit(state.copyWith(
          message: 'Word found!', wordFound: true, matches: matches));
    } else {
      audioPlayer.play(AssetSource('sounds/error.mp3'));
      emit(state
          .copyWith(message: 'Word not found!', wordFound: false, matches: []));
    }
  }

  bool _searchHorizontally(String word, List<Position> matches) {
    for (int row = 0; row < state.grid.length; row++) {
      // Left to right
      for (int col = 0; col <= state.grid[row].length - word.length; col++) {
        String segment = '';
        for (int i = 0; i < word.length; i++) {
          segment += state.grid[row][col + i];
        }
        if (segment == word) {
          for (int i = 0; i < word.length; i++) {
            matches.add(Position(row, col + i));
          }
          return true;
        }
      }

      // Right to left
      for (int col = state.grid[row].length - 1;
          col >= word.length - 1;
          col--) {
        String segment = '';
        for (int i = 0; i < word.length; i++) {
          segment += state.grid[row][col - i];
        }
        if (segment == word) {
          for (int i = 0; i < word.length; i++) {
            matches.add(Position(row, col - i));
          }
          return true;
        }
      }
    }
    return false;
  }

  bool _searchVertically(String word, List<Position> matches) {
    for (int col = 0; col < state.grid[0].length; col++) {
      // Forward direction (top to bottom)
      for (int row = 0; row <= state.grid.length - word.length; row++) {
        String verticalWord = '';
        for (int k = 0; k < word.length; k++) {
          verticalWord += state.grid[row + k][col];
        }
        if (verticalWord == word) {
          for (int i = 0; i < word.length; i++) {
            matches.add(Position(row + i, col));
          }
          return true;
        }
      }

      // Backward direction (bottom to top)
      for (int row = state.grid.length - 1; row >= word.length - 1; row--) {
        String verticalWord = '';
        for (int k = 0; k < word.length; k++) {
          verticalWord += state.grid[row - k][col];
        }
        if (verticalWord == word) {
          for (int i = 0; i < word.length; i++) {
            matches.add(Position(row - i, col));
          }
          return true;
        }
      }
    }
    return false;
  }

  bool _searchDiagonally(String word, List<Position> matches) {
    for (int row = 0; row <= state.grid.length - word.length; row++) {
      for (int col = 0; col <= state.grid[row].length - word.length; col++) {
        // Diagonal top-left to bottom-right
        String diagonalWord = '';
        for (int k = 0; k < word.length; k++) {
          diagonalWord += state.grid[row + k][col + k];
        }
        if (diagonalWord == word) {
          for (int i = 0; i < word.length; i++) {
            matches.add(Position(row + i, col + i));
          }
          return true;
        }

        // Diagonal top-right to bottom-left
        diagonalWord = '';
        for (int k = 0; k < word.length; k++) {
          diagonalWord += state.grid[row + k][col + word.length - 1 - k];
        }
        if (diagonalWord == word) {
          for (int i = 0; i < word.length; i++) {
            matches.add(Position(row + i, col + word.length - 1 - i));
          }
          return true;
        }

        // Diagonal bottom-left to top-right
        diagonalWord = '';
        for (int k = 0; k < word.length; k++) {
          diagonalWord += state.grid[row + word.length - 1 - k][col + k];
        }
        if (diagonalWord == word) {
          for (int i = 0; i < word.length; i++) {
            matches.add(Position(row + word.length - 1 - i, col + i));
          }
          return true;
        }

        // Diagonal bottom-right to top-left
        diagonalWord = '';
        for (int k = 0; k < word.length; k++) {
          diagonalWord +=
              state.grid[row + word.length - 1 - k][col + word.length - 1 - k];
        }
        if (diagonalWord == word) {
          for (int i = 0; i < word.length; i++) {
            matches.add(
                Position(row + word.length - 1 - i, col + word.length - 1 - i));
          }
          return true;
        }
      }
    }
    return false;
  }
}
