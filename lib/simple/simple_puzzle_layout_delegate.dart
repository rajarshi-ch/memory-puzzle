import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/simple/simple.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';
import 'package:rive/rive.dart';
import 'package:flutter/rendering.dart';

/// {@template simple_puzzle_layout_delegate}
/// A delegate for computing the layout of the puzzle UI
/// that uses a [SimpleTheme].
/// {@endtemplate}
class SimplePuzzleLayoutDelegate extends PuzzleLayoutDelegate {
  /// {@macro simple_puzzle_layout_delegate}
  const SimplePuzzleLayoutDelegate();

  @override
  Widget startSectionBuilder(PuzzleState state) {
    return ResponsiveLayoutBuilder(
      small: (_, child) => child!,
      medium: (_, child) => child!,
      large: (_, child) => Padding(
        padding: const EdgeInsets.only(left: 50, right: 32),
        child: child,
      ),
      child: (_) => SimpleStartSection(state: state),
    );
  }

  @override
  Widget endSectionBuilder(PuzzleState state) {
    return Column(
      children: [
        const ResponsiveGap(
          small: 32,
          medium: 48,
        ),
        ResponsiveLayoutBuilder(
          small: (_, child) => const SimplePuzzleShuffleButton(),
          medium: (_, child) => const SimplePuzzleShuffleButton(),
          large: (_, __) => const SizedBox(),
        ),
        const ResponsiveGap(
          small: 32,
          medium: 48,
        ),
      ],
    );
  }

  @override
  Widget backgroundBuilder(PuzzleState state, BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: ResponsiveLayoutBuilder(
        small: (_, __) => SizedBox(
          width: 184,
          height: 118,
          child: InkWell(
            onTap: () => _showMyDialog(context),
            child: const RiveAnimation.asset('rive/face.riv'),
          ),
        ),
        medium: (_, __) => SizedBox(
          width: 380.44,
          height: 214,
          child: InkWell(
            onTap: () => _showMyDialog(context),
            child: const RiveAnimation.asset('rive/face.riv'),
          ),
        ),
        large: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 53),
          child: SizedBox(
              width: 568.99,
              height: 320,
              child: InkWell(
                onTap: () => _showMyDialog(context),
                child: const RiveAnimation.asset('rive/face.riv'),
              ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 300,
                height: 300,
                margin: const EdgeInsets.only(top: 30, bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.shade100,
                  borderRadius: BorderRadius.circular(16.0),
                  border:
                      Border.all(width: 2.0, color: const Color(0xFF336083)),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 24.0,
                  ),
                  children: _dialogContent(context),
                ),
              ),
              Image.asset(
                'assets/images/settings_banner.png',
                width: 200,
              ),
              Positioned(
                bottom: 0,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Text('CLOSE', style: TextStyle(height: 1)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  List<Widget> _dialogContent(
    BuildContext context,
  ) {
    return [
      const SizedBox(height: 32.0),
      Text(
        'Instructions',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 12.0),
      const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Text(
            'There are 16 hidden cards, with the numbers 1 - 8 each'
                ' occurring twice. The cards are distributed randomly, '
                'click to flip the cards and use your memory to match and '
                'find the same value cards. Try to complete it in lesser '
                'than 35 moves!\n\n'

        ),
      ),
      const SizedBox(height: 2.0),
      Text(
        'Credits',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 12.0),
      const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Text(
          'Designed and developed by Rajarshi Chakraborty.\n\n'

        ),
      ),
      const SizedBox(height: 16.0),
    ];
  }

  @override
  Widget boardBuilder(int size, List<Widget> tiles) {
    return Column(
      children: [
        const ResponsiveGap(
          small: 32,
          medium: 48,
          large: 96,
        ),
        ResponsiveLayoutBuilder(
          small: (_, __) => SizedBox.square(
            dimension: _BoardSize.small,
            child: SimplePuzzleBoard(
              key: const Key('simple_puzzle_board_small'),
              size: size,
              tiles: tiles,
              spacing: 5,
            ),
          ),
          medium: (_, __) => SizedBox.square(
            dimension: _BoardSize.medium,
            child: SimplePuzzleBoard(
              key: const Key('simple_puzzle_board_medium'),
              size: size,
              tiles: tiles,
            ),
          ),
          large: (_, __) => SizedBox.square(
            dimension: _BoardSize.large,
            child: SimplePuzzleBoard(
              key: const Key('simple_puzzle_board_large'),
              size: size,
              tiles: tiles,
            ),
          ),
        ),
        const ResponsiveGap(
          large: 96,
        ),
      ],
    );
  }

  @override
  Widget tileBuilder(Tile tile, PuzzleState state) {
    return ResponsiveLayoutBuilder(
      small: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_small'),
        tile: tile,
        tileFontSize: _TileFontSize.small,
        state: state,
      ),
      medium: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_medium'),
        tile: tile,
        tileFontSize: _TileFontSize.medium,
        state: state,
      ),
      large: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_large'),
        tile: tile,
        tileFontSize: _TileFontSize.large,
        state: state,
      ),
    );
  }

  // TODO(raj): Implement simple back builder.
  @override
  Widget tileBackBuilder(Tile tile, PuzzleState state) {
    return ResponsiveLayoutBuilder(
      small: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_small'),
        tile: tile,
        tileFontSize: _TileFontSize.small,
        state: state,
      ),
      medium: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_medium'),
        tile: tile,
        tileFontSize: _TileFontSize.medium,
        state: state,
      ),
      large: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_large'),
        tile: tile,
        tileFontSize: _TileFontSize.large,
        state: state,
      ),
    );
  }

  @override
  Widget whitespaceTileBuilder() {
    return const SizedBox();
  }

  @override
  List<Object?> get props => [];
}

/// {@template simple_start_section}
/// Displays the start section of the puzzle based on [state].
/// {@endtemplate}
@visibleForTesting
class SimpleStartSection extends StatelessWidget {
  /// {@macro simple_start_section}
  const SimpleStartSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  /// The state of the puzzle.
  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveGap(
          small: 20,
          medium: 83,
          large: 151,
        ),
        PuzzleName(
          key: puzzleNameKey,
        ),
        const ResponsiveGap(large: 16),
        SimplePuzzleTitle(
          status: state.puzzleStatus,
        ),
        const ResponsiveGap(
          small: 12,
          medium: 16,
          large: 32,
        ),
        NumberOfMovesAndTilesLeft(
          key: numberOfMovesAndTilesLeftKey,
          numberOfMoves: state.numberOfMoves,
          numberOfTilesLeft: state.numberOfTilesLeft,
        ),
        const ResponsiveGap(
          large: 32,
          small: 16,
        ),
        ResponsiveLayoutBuilder(
          small: (_, __) => const SizedBox(),
          medium: (_, __) => const SizedBox(),
          large: (_, __) => const SimplePuzzleShuffleButton(),
        ),
      ],
    );
  }
}

/// {@template simple_puzzle_title}
/// Displays the title of the puzzle based on [status].
///
/// Shows the success state when the puzzle is completed,
/// otherwise defaults to the Puzzle Challenge title.
/// {@endtemplate}
@visibleForTesting
class SimplePuzzleTitle extends StatelessWidget {
  /// {@macro simple_puzzle_title}
  const SimplePuzzleTitle({
    Key? key,
    required this.status,
  }) : super(key: key);

  /// The status of the puzzle.
  final PuzzleStatus status;

  @override
  Widget build(BuildContext context) {
    return PuzzleTitle(
      key: puzzleTitleKey,
      title: status == PuzzleStatus.complete
          ? context.l10n.puzzleCompleted
          : context.l10n.puzzleChallengeTitle,
    );
  }
}

abstract class _BoardSize {
  static double small = 312;
  static double medium = 424;
  static double large = 472;
}

/// {@template simple_puzzle_board}
/// Display the board of the puzzle in a [size]x[size] layout
/// filled with [tiles]. Each tile is spaced with [spacing].
/// {@endtemplate}
@visibleForTesting
class SimplePuzzleBoard extends StatelessWidget {
  /// {@macro simple_puzzle_board}
  const SimplePuzzleBoard({
    Key? key,
    required this.size,
    required this.tiles,
    this.spacing = 8,
  }) : super(key: key);

  /// The size of the board.
  final int size;

  /// The tiles to be displayed on the board.
  final List<Widget> tiles;

  /// The spacing between each tile from [tiles].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: size,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: tiles,
    );
  }
}

abstract class _TileFontSize {
  static double small = 36;
  static double medium = 50;
  static double large = 54;
}

const Map<int, String> _tileValueLabelMap = {
  1: '1',
  2: '1',
  3: '2',
  4: '2',
  5: '3',
  6: '3',
  7: '4',
  8: '4',
  9: '5',
  10: '5',
  11: '6',
  12: '6',
  13: '7',
  14: '7',
  15: '8',
  16: '8',
};

/// {@template simple_puzzle_tile}
/// Displays the puzzle tile associated with [tile] and
/// the font size of [tileFontSize] based on the puzzle [state].
/// {@endtemplate}
@visibleForTesting
class SimplePuzzleTile extends StatelessWidget {
  /// {@macro simple_puzzle_tile}
  const SimplePuzzleTile({
    Key? key,
    required this.tile,
    required this.tileFontSize,
    required this.state,
  }) : super(key: key);

  /// The tile to be displayed.
  final Tile tile;

  /// The font size of the tile to be displayed.
  final double tileFontSize;

  /// The state of the puzzle.
  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return TextButton(
      style: TextButton.styleFrom(
        primary: PuzzleColors.white,
        textStyle: PuzzleTextStyle.headline2.copyWith(
          fontSize: tileFontSize,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ).copyWith(
        foregroundColor: MaterialStateProperty.all(PuzzleColors.white),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (states) {
            if (tile.isFaceUp) {
              return theme.pressedColor;
            } else if (states.contains(MaterialState.hovered)) {
              return theme.hoverColor;
            } else {
              return theme.defaultColor;
            }
          },
        ),
        side: MaterialStateBorderSide.resolveWith((states) {
          if (tile.isFaceUp) {
            if (state.puzzleIntermediateStatus ==
                PuzzleIntermediateStatus.wrongMatch) {
              return const BorderSide(
                color: Colors.red,
                width: 4,
              );
            } else if (state.puzzleIntermediateStatus ==
                PuzzleIntermediateStatus.correctMatch) {
              return const BorderSide(
                color: Colors.green,
                width: 4,
              );
            } else {
              return null;
            }
          } else {
            return null;
          }
        }),
      ),
      onPressed: state.puzzleStatus == PuzzleStatus.incomplete
          ? () => context.read<PuzzleBloc>().add(TileTapped(tile))
          : null,
      child: tile.isFaceUp
          ? Text(
              _tileValueLabelMap[tile.value] ?? '',
              semanticsLabel: context.l10n.puzzleTileLabelText(
                tile.value.toString(),
                tile.currentPosition.x.toString(),
                tile.currentPosition.y.toString(),
              ),
            )
          : const SizedBox(),
    );
  }
}

/// {@template puzzle_shuffle_button}
/// Displays the button to shuffle the puzzle.
/// {@endtemplate}
@visibleForTesting
class SimplePuzzleShuffleButton extends StatelessWidget {
  /// {@macro puzzle_shuffle_button}
  const SimplePuzzleShuffleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PuzzleButton(
      textColor: PuzzleColors.primary0,
      backgroundColor: PuzzleColors.primary6,
      onPressed: () => context.read<PuzzleBloc>().add(const PuzzleReset()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/shuffle_icon.png',
            width: 17,
            height: 17,
          ),
          const Gap(10),
          Text(context.l10n.puzzleShuffle),
        ],
      ),
    );
  }
}
