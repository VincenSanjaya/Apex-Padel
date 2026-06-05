import '../models/match_record.dart';

class RatingCalculator {
  static const double baseRating = 0.0;
  static const double minRating = 0.0;
  static const double maxRating = 10.0;

  /// Calculates the new rating based on the existing rating, match data, and logic rules.
  static double calculateNewRating(double currentRating, ScoringFormat format, String scoreData) {
    double ratingChange = calculateRatingChange(format, scoreData);
    double newRating = currentRating + ratingChange;

    // Ensure rating is between min and max
    if (newRating < minRating) {
      newRating = minRating;
    } else if (newRating > maxRating) {
      newRating = maxRating;
    }

    // Format to 1 decimal place
    return double.parse(newRating.toStringAsFixed(1));
  }

  /// Calculates the raw rating change based on the score data and format.
  static double calculateRatingChange(ScoringFormat format, String scoreData) {
    if (format == ScoringFormat.traditional) {
      return _calculateTraditional(scoreData);
    } else {
      return _calculatePoints(scoreData);
    }
  }

  static double _calculateTraditional(String scoreData) {
    int totalGamesWon = 0;
    int totalGamesLost = 0;

    // Example scoreData: "6-4, 7-5"
    List<String> sets = scoreData.split(',');
    for (String setScore in sets) {
      List<String> games = setScore.trim().split('-');
      if (games.length == 2) {
        int? myGames = int.tryParse(games[0].trim());
        int? opponentGames = int.tryParse(games[1].trim());

        if (myGames != null && opponentGames != null) {
          totalGamesWon += myGames;
          totalGamesLost += opponentGames;
        }
      }
    }

    int gameDiff = totalGamesWon - totalGamesLost;

    if (gameDiff >= 6) {
      return 0.15; // Dominant Win
    } else if (gameDiff > 0 && gameDiff < 6) {
      return 0.08; // Standard Win
    } else if (gameDiff == 0) {
      return 0.0; // Draw
    } else if (gameDiff >= -4 && gameDiff < 0) {
      return -0.02; // Close Loss
    } else {
      // gameDiff < -4
      return -0.10; // Heavy Loss
    }
  }

  static double _calculatePoints(String scoreData) {
    // Example scoreData: "21-16"
    List<String> points = scoreData.trim().split('-');
    if (points.length != 2) return 0.0;

    int? myPoints = int.tryParse(points[0].trim());
    int? opponentPoints = int.tryParse(points[1].trim());

    if (myPoints == null || opponentPoints == null) return 0.0;

    int pointDiff = myPoints - opponentPoints;

    if (pointDiff >= 8) {
      return 0.15; // Dominant Win
    } else if (pointDiff > 3 && pointDiff < 8) {
      return 0.08; // Standard Win
    } else if (pointDiff > 0 && pointDiff <= 3) {
      return 0.05; // Close Win
    } else if (pointDiff == 0) {
      return 0.0; // Draw
    } else if (pointDiff >= -3 && pointDiff < 0) {
      return -0.02; // Close Loss
    } else if (pointDiff > -8 && pointDiff < -3) {
      return -0.05; // Standard Loss
    } else {
      // pointDiff <= -8
      return -0.10; // Heavy Loss
    }
  }

  /// Derives MatchResult purely from rating change for easy logging
  static MatchResult deriveResult(double ratingChange) {
    if (ratingChange > 0) return MatchResult.win;
    if (ratingChange < 0) return MatchResult.loss;
    return MatchResult.draw;
  }
}
