// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc(this._size, {this.random}) : super(const PuzzleState()) {
    on<PuzzleInitialized>(_onPuzzleInitialized);
    on<TileTapped>(_onTileTapped);
    on<PuzzleReset>(_onPuzzleReset);
  }

  final int _size;

  final Random? random;

  void _onPuzzleInitialized(
    PuzzleInitialized event,
    Emitter<PuzzleState> emit,
  ) {
    final puzzle = _generatePuzzle(_size, shuffle: event.shufflePuzzle);
    emit(
      PuzzleState(
        puzzle: puzzle.sort(),
        numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
      ),
    );
  }

  Future<void> _onTileTapped(TileTapped event, Emitter<PuzzleState> emit) async {
    final tappedTile = event.tile;
    var delay = const Duration(milliseconds: 1000);
    if (state.puzzleStatus == PuzzleStatus.incomplete) {
      final mutablePuzzle = Puzzle(tiles: [...state.puzzle.tiles]);
      //final puzzle = mutablePuzzle.moveTiles(tappedTile, []);
      final puzzle = mutablePuzzle.flipTile(tappedTile);
      debugPrint(tappedTile.toString());
      debugPrint(state.lastTappedTile.toString());

      // Compare tappedTile.value to state.lastTappedTile.value to build logic
      // state.lastTappedTile can be null, if first click
      

      if (puzzle.isComplete()) {
        emit(
          state.copyWith(
            puzzle: puzzle.sort(),
            puzzleStatus: PuzzleStatus.complete,
            tileMovementStatus: TileMovementStatus.moved,
            numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
            numberOfMoves: state.numberOfMoves + 1,
            lastTappedTile: tappedTile,
          ),
        );
      } else {
        emit(
          state.copyWith(
            puzzle: puzzle.sort(),
            tileMovementStatus: TileMovementStatus.moved,
            numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
            numberOfMoves: state.numberOfMoves + 1,
            lastTappedTile: tappedTile,
          ),
        );

        /// Id remaining cards are even after a click, that means
        /// time to compare open cards
        if(puzzle.getNumberOfRemainingCards().isEven){

          if(puzzle.areTilesMatching()){
            emit(
              state.copyWith(puzzleIntermediateStatus:
              PuzzleIntermediateStatus.correctMatch,),
            );

            await Future.delayed(delay, () {
              _removeMatchingCards(emit);
            });
          }else {
            /// After two non matching cards are flipped, flip all cards face down
            /// after a delay
            emit(
              state.copyWith(puzzleIntermediateStatus:
              PuzzleIntermediateStatus.wrongMatch,),
            );
            await Future.delayed(delay, () {
              _flipAllCardsBack(emit);
            });
          }

        } else {
          emit(
            state.copyWith(puzzleIntermediateStatus:
            PuzzleIntermediateStatus.neutral,),
          );
        }
      }

      if (state.puzzle.isTileMovable(tappedTile)) {

      } else {
        emit(
          state.copyWith(tileMovementStatus: TileMovementStatus.cannotBeMoved),
        );
      }
    } else {
      emit(
        state.copyWith(tileMovementStatus: TileMovementStatus.cannotBeMoved),
      );
    }
  }

  void _flipAllCardsBack(Emitter<PuzzleState> emit){
    final mutablePuzzle = Puzzle(tiles: [...state.puzzle.tiles]);
    final puzzle = mutablePuzzle.flipAllTilesBack();
    emit(
      state.copyWith(
        puzzle: puzzle.sort(),
        puzzleStatus: PuzzleStatus.incomplete,
        tileMovementStatus: TileMovementStatus.moved,
        numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
        numberOfMoves: state.numberOfMoves + 1,
        lastTappedTile: null,
      ),
    );
  }

  /// Removes matching cards from the board
  void _removeMatchingCards(Emitter<PuzzleState> emit){
    final mutablePuzzle = Puzzle(tiles: [...state.puzzle.tiles]);
    final puzzle = mutablePuzzle.removeMatchingCards();
    emit(
      state.copyWith(
        puzzle: puzzle.sort(),
        puzzleStatus: PuzzleStatus.incomplete,
        tileMovementStatus: TileMovementStatus.moved,
        numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
        numberOfMoves: state.numberOfMoves + 1,
        lastTappedTile: null,
      ),
    );
  }

  void _onPuzzleReset(PuzzleReset event, Emitter<PuzzleState> emit) {
    final puzzle = _generatePuzzle(_size);
    emit(
      PuzzleState(
        puzzle: puzzle.sort(),
        numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
      ),
    );
  }

  /// Build a randomized, solvable puzzle of the given size.
  Puzzle _generatePuzzle(int size, {bool shuffle = true}) {
    final correctPositions = <Position>[];
    final currentPositions = <Position>[];
    final whitespacePosition = Position(x: size, y: size);

    // Create all possible board positions.
    for (var y = 1; y <= size; y++) {
      for (var x = 1; x <= size; x++) {
        if (x == size && y == size) {
          correctPositions.add(whitespacePosition);
          currentPositions.add(whitespacePosition);
        } else {
          final position = Position(x: x, y: y);
          correctPositions.add(position);
          currentPositions.add(position);
        }
      }
    }

    if (shuffle) {
      // Randomize only the current tile posistions.
      currentPositions.shuffle(random);
    }

    var tiles = _getTileListFromPositions(
      size,
      correctPositions,
      currentPositions,
    );

    var puzzle = Puzzle(tiles: tiles);

    // if (shuffle) {
    //   // Assign the tiles new current positions until the puzzle is solvable and
    //   // zero tiles are in their correct position.
    //   while (!puzzle.isSolvable() || puzzle.getNumberOfCorrectTiles() != 0) {
    //     currentPositions.shuffle(random);
    //     tiles = _getTileListFromPositions(
    //       size,
    //       correctPositions,
    //       currentPositions,
    //     );
    //     puzzle = Puzzle(tiles: tiles);
    //   }
    // }

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<Tile> _getTileListFromPositions(
    int size,
    List<Position> correctPositions,
    List<Position> currentPositions,
  ) {
    final whitespacePosition = Position(x: size, y: size);
    return [
      for (int i = 1; i <= size * size; i++)

          Tile(
            value: i,
            correctPosition: correctPositions[i - 1],
            currentPosition: currentPositions[i - 1],

          )
    ];
  }
}
