import 'package:equatable/equatable.dart';

abstract class CrosswordEvent extends Equatable {
  const CrosswordEvent();
}

class InitializeGrid extends CrosswordEvent {
  final int rows;
  final int cols;

  const InitializeGrid(this.rows, this.cols);

  @override
  List<Object?> get props => [rows, cols];
}

class UpdateCell extends CrosswordEvent {
  final int row;
  final int col;
  final String letter;

  const UpdateCell(this.row, this.col, this.letter);

  @override
  List<Object?> get props => [row, col, letter];
}

class SearchWord extends CrosswordEvent {
  final String word;

  const SearchWord(this.word);

  @override
  List<Object?> get props => [word];
}
