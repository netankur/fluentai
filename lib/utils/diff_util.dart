enum DiffType { unchanged, added, deleted }

class DiffSegment {
  final String text;
  final DiffType type;

  const DiffSegment(this.text, this.type);
}

class DiffUtil {
  /// Computes a word-by-word diff between original and corrected text.
  static List<DiffSegment> calculateDiff(String original, String corrected) {
    final origWords = _tokenize(original);
    final corrWords = _tokenize(corrected);

    final matrix = List.generate(
      origWords.length + 1,
      (_) => List<int>.filled(corrWords.length + 1, 0),
    );

    for (int i = 0; i < origWords.length; i++) {
      for (int j = 0; j < corrWords.length; j++) {
        if (origWords[i] == corrWords[j]) {
          matrix[i + 1][j + 1] = matrix[i][j] + 1;
        } else {
          matrix[i + 1][j + 1] = matrix[i + 1][j] > matrix[i][j + 1]
              ? matrix[i + 1][j]
              : matrix[i][j + 1];
        }
      }
    }

    int i = origWords.length;
    int j = corrWords.length;
    final List<DiffSegment> reversedSegments = [];

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && origWords[i - 1] == corrWords[j - 1]) {
        reversedSegments.add(DiffSegment(origWords[i - 1], DiffType.unchanged));
        i--;
        j--;
      } else if (j > 0 && (i == 0 || matrix[i][j - 1] >= matrix[i - 1][j])) {
        reversedSegments.add(DiffSegment(corrWords[j - 1], DiffType.added));
        j--;
      } else if (i > 0 && (j == 0 || matrix[i][j - 1] < matrix[i - 1][j])) {
        reversedSegments.add(DiffSegment(origWords[i - 1], DiffType.deleted));
        i--;
      }
    }

    final segments = reversedSegments.reversed.toList();
    return _mergeAdjacentSegments(segments);
  }

  static List<String> _tokenize(String text) {
    final RegExp regExp = RegExp(r'(\s+|[^\s\w]+|\w+)');
    return regExp.allMatches(text).map((m) => m.group(0)!).toList();
  }

  static List<DiffSegment> _mergeAdjacentSegments(List<DiffSegment> list) {
    if (list.isEmpty) return [];
    final List<DiffSegment> merged = [];
    DiffSegment current = list.first;

    for (int k = 1; k < list.length; k++) {
      final next = list[k];
      if (current.type == next.type) {
        current = DiffSegment(current.text + next.text, current.type);
      } else {
        merged.add(current);
        current = next;
      }
    }
    merged.add(current);
    return merged;
  }
}
