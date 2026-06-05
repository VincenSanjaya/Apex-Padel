import 'package:flutter_test/flutter_test.dart';
import 'package:apex_padel/utils/rating_calculator.dart';
import 'package:apex_padel/models/match_record.dart';

void main() {
  group('RatingCalculator Tests', () {
    test('Traditional Scoring Logic', () {
      // Branch A: Traditional Format (Sets)
      // Dominant Win (>= 6) -> +0.15
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.traditional, "6-0, 6-0"), 0.15); // diff = 12
      
      // Standard Win (0 < diff < 6) -> +0.08
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.traditional, "6-4, 6-4"), 0.08); // diff = 4
      
      // Draw (diff == 0) -> 0.0
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.traditional, "6-6, 6-6"), 0.0); // diff = 0
      
      // Close Loss (-4 <= diff < 0) -> -0.02
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.traditional, "4-6, 4-6"), -0.02); // diff = -4
      
      // Heavy Loss (diff < -4) -> -0.10
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.traditional, "2-6, 2-6"), -0.10); // diff = -8
    });

    test('Points Scoring Logic', () {
      // Branch B: Points Format
      // Dominant Win (>= 8) -> +0.15
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.points, "21-10"), 0.15); // diff = 11
      
      // Standard Win (3 < diff < 8) -> +0.08
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.points, "21-16"), 0.08); // diff = 5
      
      // Close Win (0 < diff <= 3) -> +0.05
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.points, "21-19"), 0.05); // diff = 2
      
      // Draw (diff == 0) -> 0.0
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.points, "15-15"), 0.0); // diff = 0
      
      // Close Loss (-3 <= diff < 0) -> -0.02
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.points, "18-21"), -0.02); // diff = -3
      
      // Standard Loss (-8 < diff < -3) -> -0.05
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.points, "16-21"), -0.05); // diff = -5
      
      // Heavy Loss (diff <= -8) -> -0.10
      expect(RatingCalculator.calculateRatingChange(ScoringFormat.points, "10-21"), -0.10); // diff = -11
    });

    test('calculateNewRating bounds and format', () {
      // Ensure rating does not exceed max (10.0)
      expect(RatingCalculator.calculateNewRating(9.9, ScoringFormat.points, "21-10"), 10.0); // 9.9 + 0.15 = 10.05 -> 10.0
      
      // Ensure rating does not drop below min (0.0)
      expect(RatingCalculator.calculateNewRating(0.0, ScoringFormat.points, "10-21"), 0.0); // 0.0 - 0.10 -> 0.0

      // Format rounding check
      expect(RatingCalculator.calculateNewRating(0.0, ScoringFormat.points, "21-16"), 0.1); // 0.0 + 0.08 = 0.08 -> 0.1
    });
  });
}
