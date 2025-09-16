import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import 'bug_smash_view_model.dart';
import 'bug_smash_game.dart';

/// Bug Smash game screen
class BugSmashScreen extends StatelessWidget {
  const BugSmashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BugSmashViewModel(),
      child: const _BugSmashContent(),
    );
  }
}

class _BugSmashContent extends StatefulWidget {
  const _BugSmashContent();

  @override
  State<_BugSmashContent> createState() => _BugSmashContentState();
}

class _BugSmashContentState extends State<_BugSmashContent> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start game with screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      context.read<BugSmashViewModel>().startGame(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BugSmashViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(context, viewModel),
          body: Stack(
            children: [
              _buildGameArea(context, viewModel),
              if (viewModel.state == BugSmashGameState.checkinDialog)
                _buildCheckInDialog(context, viewModel),
              if (viewModel.state == BugSmashGameState.gameOver)
                _buildGameOverDialog(context, viewModel),
              if (viewModel.state == BugSmashGameState.paused)
                _buildPausedOverlay(viewModel),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, BugSmashViewModel viewModel) {
    return AppBar(
      title: const Text('Bug Smash'),
      actions: [
        if (viewModel.state == BugSmashGameState.playing)
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: viewModel.pauseGame,
            tooltip: 'Pause',
          ),
        if (viewModel.state == BugSmashGameState.paused)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: viewModel.resumeGame,
            tooltip: 'Resume',
          ),
      ],
    );
  }

  Widget _buildGameArea(BuildContext context, BugSmashViewModel viewModel) {
    return Column(
      children: [
        _buildGameStats(viewModel),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade50,
                  Colors.green.shade50,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                _buildBackground(),
                
                // Bugs
                ...viewModel.bugs.map((bug) => _buildBug(bug, viewModel)),
                
                // Instructions overlay for new games
                if (viewModel.state == BugSmashGameState.initial)
                  _buildInstructions(),
              ],
            ),
          ),
        ),
        _buildGameInstructions(),
      ],
    );
  }

  Widget _buildGameStats(BugSmashViewModel viewModel) {
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
            'Score',
            '${viewModel.score}',
            Icons.star,
            AppTheme.primaryColor,
          ),
          _buildStatItem(
            'Lives',
            '${viewModel.lives}',
            Icons.favorite,
            Colors.red,
          ),
          _buildStatItem(
            'Time',
            _formatDuration(viewModel.timeRemaining),
            Icons.timer,
            AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
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

  Widget _buildBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPainter(),
      ),
    );
  }

  Widget _buildBug(Bug bug, BugSmashViewModel viewModel) {
    return Positioned(
      left: bug.position.dx,
      top: bug.position.dy,
      child: GestureDetector(
        onTap: () => viewModel.smashBug(bug.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bug.isSmashed ? Colors.grey.shade300 : bug.color,
            shape: BoxShape.circle,
            boxShadow: bug.isSmashed
                ? []
                : [
                    BoxShadow(
                      color: bug.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              bug.isSmashed ? '💥' : BugSmashGame.getBugEmoji(bug.type),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
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
                Icons.bug_report,
                color: AppTheme.primaryColor,
                size: 48,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Bug Smash!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Tap bugs to smash them and release stress!\n\n'
                '• Red bugs (😰) = Stress\n'
                '• Orange bugs (😟) = Anxiety\n'
                '• Yellow bugs (😕) = Worry\n'
                '• Blue bugs (😌) = Calm (collect these!)\n'
                '• Green bugs (😊) = Joy (collect these!)',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton(
                onPressed: () {
                  final size = MediaQuery.of(context).size;
                  context.read<BugSmashViewModel>().startGame(size);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameInstructions() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      color: Colors.grey.shade100,
      child: const Text(
        'Tap the emotion bugs to release stress and anxiety. Collect calm and joy bugs for bonus points!',
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCheckInDialog(BuildContext context, BugSmashViewModel viewModel) {
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
                'Taking a moment to check in',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'I noticed you might be having a tough time. How are you feeling?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => viewModel.handleCheckInResponse(false),
                      child: const Text('I\'m okay'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => viewModel.handleCheckInResponse(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('I need support'),
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

  Widget _buildGameOverDialog(BuildContext context, BugSmashViewModel viewModel) {
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
                Icons.emoji_events,
                color: AppTheme.successColor,
                size: 64,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Game Over!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Final Score: ${viewModel.score}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Great job releasing stress and collecting positive emotions!',
                textAlign: TextAlign.center,
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
                      onPressed: () {
                        final size = MediaQuery.of(context).size;
                        viewModel.startGame(size);
                      },
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

  Widget _buildPausedOverlay(BugSmashViewModel viewModel) {
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Custom painter for background
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw subtle grid pattern
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}