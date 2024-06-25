import 'package:equatable/equatable.dart';
import 'package:word_search/position.dart';

class CrosswordState extends Equatable {
  final List<List<String>> grid;
  final List<Position> matches;
  final String message;
  final bool wordFound;

  const CrosswordState({
    required this.grid,
    this.matches = const [],
    this.message = '',
    this.wordFound = false,
  });

  CrosswordState copyWith({
    List<List<String>>? grid,
    List<Position>? matches,
    String? message,
    bool? wordFound,
  }) {
    return CrosswordState(
      grid: grid ?? this.grid,
      matches: matches ?? this.matches,
      message: message ?? this.message,
      wordFound: wordFound ?? this.wordFound,
    );
  }

  @override
  List<Object?> get props => [grid, matches, message, wordFound];
}
