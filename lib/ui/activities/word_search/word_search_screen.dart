import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import 'word_search_view_model.dart';
import 'word_search_game.dart';

/// Word Search game screen
class WordSearchScreen extends StatelessWidget {
  const WordSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordSearchViewModel(),
      child: const _WordSearchContent(),
    );
  }
}

class _WordSearchContent extends StatelessWidget {
  const _WordSearchContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<WordSearchViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(context, viewModel),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WordSearchViewModel viewModel) {
    return AppBar(
      title: const Text('Word Search'),
      actions: [
        if (viewModel.state == WordSearchGameState.playing) ...[
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: viewModel.useHint,
            tooltip: 'Hint',
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: viewModel.pauseGame,
            tooltip: 'Pause',
          ),
        ],
        if (viewModel.state == WordSearchGameState.paused)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: viewModel.resumeGame,
            tooltip: 'Resume',
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WordSearchViewModel viewModel) {
    return Stack(
      children: [
        Column(
          children: [
            _buildGameStats(viewModel),
            Expanded(
              child: _buildGameArea(context, viewModel),
            ),
            if (viewModel.state == WordSearchGameState.playing)
              _buildWordsList(context, viewModel),
          ],
        ),
        if (viewModel.state == WordSearchGameState.wordInput)
          _buildWordInputDialog(context, viewModel),
        if (viewModel.state == WordSearchGameState.initial)
          _buildWelcomeDialog(context, viewModel),
        if (viewModel.state == WordSearchGameState.checkinDialog)
          _buildCheckInDialog(context, viewModel),
        if (viewModel.state == WordSearchGameState.completed)
          _buildCompletionDialog(context, viewModel),
        if (viewModel.state == WordSearchGameState.paused)
          _buildPausedOverlay(viewModel),
      ],
    );
  }

  Widget _buildGameStats(WordSearchViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Time',
            _formatDuration(viewModel.elapsedTime),
            Icons.timer,
          ),
          _buildStatItem(
            'Found',
            '${viewModel.wordsFound}/${viewModel.totalWords}',
            Icons.check_circle,
          ),
          _buildStatItem(
            'Score',
            '${viewModel.score}',
            Icons.star,
          ),
          _buildStatItem(
            'Hints',
            '${viewModel.hintsUsed}',
            Icons.lightbulb,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGameArea(BuildContext context, WordSearchViewModel viewModel) {
    if (viewModel.game == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: AspectRatio(
          aspectRatio: 1,
          child: _buildGrid(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WordSearchViewModel viewModel) {
    final game = viewModel.game!;
    final screenSize = MediaQuery.of(context).size;
    final gridSize = math.min(screenSize.width, screenSize.height) - 32;
    final cellSize = gridSize / game.size;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: game.size,
            childAspectRatio: 1,
          ),
          itemCount: game.size * game.size,
          itemBuilder: (context, index) {
            final row = index ~/ game.size;
            final col = index % game.size;
            final position = GridPosition(row, col);
            
            return _buildGridCell(
              context,
              game.grid[row][col],
              position,
              viewModel,
              cellSize,
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridCell(
    BuildContext context,
    String letter,
    GridPosition position,
    WordSearchViewModel viewModel,
    double cellSize,
  ) {
    final isSelected = viewModel.currentSelection.contains(position);
    final isFound = viewModel.foundPositions.contains(position);
    
    return GestureDetector(
      onPanStart: (details) => viewModel.startSelection(position),
      onPanUpdate: (details) {
        // Convert global position to grid position
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        final row = (localPosition.dy / cellSize).floor();
        final col = (localPosition.dx / cellSize).floor();
        
        if (row >= 0 && row < viewModel.game!.size && 
            col >= 0 && col < viewModel.game!.size) {
          viewModel.updateSelection(GridPosition(row, col));
        }
      },
      onPanEnd: (details) => viewModel.endSelection(),
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(isSelected, isFound),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: math.min(cellSize * 0.6, 18),
              fontWeight: FontWeight.bold,
              color: isSelected || isFound ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Color _getCellColor(bool isSelected, bool isFound) {
    if (isFound) return AppTheme.successColor;
    if (isSelected) return AppTheme.primaryColor;
    return Colors.white;
  }

  Widget _buildWordsList(BuildContext context, WordSearchViewModel viewModel) {
    if (viewModel.game == null) return const SizedBox.shrink();

    return Container(
      height: 120,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find these words:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                mainAxisSpacing: AppTheme.spacingS,
                crossAxisSpacing: AppTheme.spacingS,
              ),
              itemCount: viewModel.game!.words.length,
              itemBuilder: (context, index) {
                final word = viewModel.game!.words[index];
                return _buildWordChip(word);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordChip(WordSearchWord word) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: word.isFound ? AppTheme.successColor : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: word.isFound ? AppTheme.successColor : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (word.isFound)
            const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          if (word.isFound) const SizedBox(width: AppTheme.spacingXS),
          Expanded(
            child: Text(
              word.text,
              style: TextStyle(
                color: word.isFound ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInDialog(BuildContext context, WordSearchViewModel viewModel) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacingL),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                color: AppTheme.primaryColor,
                size: 48,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Just checking in!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'How are you feeling? Sometimes taking a break or getting support can help.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => viewModel.handleCheckInResponse(false),
                      child: const Text('I\'m doing okay'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => viewModel.handleCheckInResponse(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('I could use support'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionDialog(BuildContext context, WordSearchViewModel viewModel) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacingL),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                color: AppTheme.successColor,
                size: 64,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'You found all words!\nFinal Score: ${viewModel.score}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Time: ${_formatDuration(viewModel.elapsedTime)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => viewModel.startNewGame(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Play Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPausedOverlay(WordSearchViewModel viewModel) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle,
                color: AppTheme.primaryColor,
                size: 48,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Game Paused',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              ElevatedButton(
                onPressed: viewModel.resumeGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Resume'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeDialog(BuildContext context, WordSearchViewModel viewModel) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacingL),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search,
                color: AppTheme.primaryColor,
                size: 48,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Word Search Puzzle',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Find words by dragging from the first letter to the last letter. '
                'You can choose your own words or use our default collection!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => viewModel.startNewGame(),
                      child: const Text('Use Default Words'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => viewModel.showWordInput(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Choose My Words'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordInputDialog(BuildContext context, WordSearchViewModel viewModel) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacingL),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Your Words',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Add words you want to find in the puzzle (minimum 3 letters each):',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: viewModel.wordInputController,
                decoration: const InputDecoration(
                  hintText: 'Enter a word...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => viewModel.addUserWord(value),
              ),
              const SizedBox(height: AppTheme.spacingM),
              ElevatedButton(
                onPressed: () => viewModel.addUserWord(viewModel.wordInputController.text),
                child: const Text('Add Word'),
              ),
              const SizedBox(height: AppTheme.spacingM),
              if (viewModel.userWords.isNotEmpty) ...[
                const Text('Your Words:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppTheme.spacingS),
                Wrap(
                  spacing: 8,
                  children: viewModel.userWords.map((word) => Chip(
                    label: Text(word),
                    onDeleted: () => viewModel.removeUserWord(word),
                  )).toList(),
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => viewModel.startNewGame(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: viewModel.userWords.isNotEmpty 
                          ? () => viewModel.startNewGame()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Start Game'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}