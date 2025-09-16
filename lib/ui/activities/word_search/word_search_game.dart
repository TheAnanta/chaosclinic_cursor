import 'dart:math';

/// Word Search game model
class WordSearchGame {
  final List<List<String>> grid;
  final List<WordSearchWord> words;
  final int size;
  
  WordSearchGame({
    required this.grid,
    required this.words,
    required this.size,
  });

  /// Check if a word is found at the given positions
  bool isWordFound(List<GridPosition> positions) {
    if (positions.length < 2) return false;
    
    final word = positions.map((pos) => grid[pos.row][pos.col]).join();
    return words.any((w) => w.text.toLowerCase() == word.toLowerCase());
  }

  /// Get the word that matches the given positions
  WordSearchWord? getFoundWord(List<GridPosition> positions) {
    if (positions.length < 2) return null;
    
    final word = positions.map((pos) => grid[pos.row][pos.col]).join();
    return words.firstWhere(
      (w) => w.text.toLowerCase() == word.toLowerCase(),
      orElse: () => throw StateError('Word not found'),
    );
  }
}

class WordSearchWord {
  final String text;
  final List<GridPosition> positions;
  bool isFound;
  
  WordSearchWord({
    required this.text,
    required this.positions,
    this.isFound = false,
  });
}

class GridPosition {
  final int row;
  final int col;
  
  GridPosition(this.row, this.col);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

/// Word Search game generator
class WordSearchGenerator {
  static const int defaultSize = 15;
  static final Random _random = Random();
  
  /// Generate a new word search puzzle
  static WordSearchGame generate({
    int size = defaultSize,
    List<String>? customWords,
  }) {
    final words = customWords ?? _getDefaultWords();
    final grid = List.generate(size, (_) => List.filled(size, ''));
    final placedWords = <WordSearchWord>[];
    
    // Place words in the grid
    for (final word in words.take(8)) { // Limit to 8 words for manageable size
      final wordUpper = word.toUpperCase();
      final positions = _placeWordInGrid(grid, wordUpper, size);
      if (positions.isNotEmpty) {
        placedWords.add(WordSearchWord(
          text: wordUpper,
          positions: positions,
        ));
      }
    }
    
    // Fill empty cells with random letters
    _fillEmptyCells(grid, size);
    
    return WordSearchGame(
      grid: grid,
      words: placedWords,
      size: size,
    );
  }
  
  static List<GridPosition> _placeWordInGrid(
    List<List<String>> grid,
    String word,
    int size,
  ) {
    final directions = [
      [0, 1],   // Horizontal
      [1, 0],   // Vertical
      [1, 1],   // Diagonal down-right
      [1, -1],  // Diagonal down-left
    ];
    
    // Try to place the word 50 times
    for (int attempt = 0; attempt < 50; attempt++) {
      final direction = directions[_random.nextInt(directions.length)];
      final startRow = _random.nextInt(size);
      final startCol = _random.nextInt(size);
      
      if (_canPlaceWord(grid, word, startRow, startCol, direction, size)) {
        return _placeWord(grid, word, startRow, startCol, direction);
      }
    }
    
    return [];
  }
  
  static bool _canPlaceWord(
    List<List<String>> grid,
    String word,
    int startRow,
    int startCol,
    List<int> direction,
    int size,
  ) {
    final endRow = startRow + (word.length - 1) * direction[0];
    final endCol = startCol + (word.length - 1) * direction[1];
    
    if (endRow < 0 || endRow >= size || endCol < 0 || endCol >= size) {
      return false;
    }
    
    for (int i = 0; i < word.length; i++) {
      final row = startRow + i * direction[0];
      final col = startCol + i * direction[1];
      
      if (grid[row][col].isNotEmpty && grid[row][col] != word[i]) {
        return false;
      }
    }
    
    return true;
  }
  
  static List<GridPosition> _placeWord(
    List<List<String>> grid,
    String word,
    int startRow,
    int startCol,
    List<int> direction,
  ) {
    final positions = <GridPosition>[];
    
    for (int i = 0; i < word.length; i++) {
      final row = startRow + i * direction[0];
      final col = startCol + i * direction[1];
      grid[row][col] = word[i];
      positions.add(GridPosition(row, col));
    }
    
    return positions;
  }
  
  static void _fillEmptyCells(List<List<String>> grid, int size) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col].isEmpty) {
          grid[row][col] = letters[_random.nextInt(letters.length)];
        }
      }
    }
  }
  
  static List<String> _getDefaultWords() {
    return [
      'CALM',
      'PEACE',
      'HAPPY',
      'SMILE',
      'JOY',
      'LOVE',
      'HOPE',
      'MIND',
      'HEART',
      'BREATHE',
      'RELAX',
      'FOCUS',
      'STRONG',
      'BRAVE',
      'KIND',
      'GENTLE',
      'TRUST',
      'FAITH',
      'HEAL',
      'GROW',
    ];
  }
}