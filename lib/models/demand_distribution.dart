import 'dart:math';
import 'day_simulation_entry.dart';

class DemandEntry {
  final int demand;
  final double probability;
  final double cumulativeProbability;
  final String randomDigitAssignment;

  DemandEntry({
    required this.demand,
    required this.probability,
    required this.cumulativeProbability,
    required this.randomDigitAssignment,
  });
}

class DayTypeEntry {
  final String dayType;
  final double probability;
  final double cumulativeProbability;
  final String randomDigitAssignment;

  DayTypeEntry({
    required this.dayType,
    required this.probability,
    required this.cumulativeProbability,
    required this.randomDigitAssignment,
  });
}

class DemandDistribution {
  // Fixed day type probabilities from the problem
  static final Map<String, double> dayTypeProbabilities = {
    'High': 0.4,
    'Medium': 0.3,
    'Low': 0.3,
  };

  static List<DayTypeEntry> getDayTypeProbabilities() {
    List<DayTypeEntry> entries = [];
    double cumulative = 0.0;

    dayTypeProbabilities.forEach((dayType, probability) {
      double previousCumulative = cumulative;
      cumulative += probability;

      // Calculate random digit assignment using ma'am's method
      int rangeStart = (previousCumulative * 100).round() + 1;
      int rangeEnd = (cumulative * 100).round();

      // Handle the wrap-around case (e.g., 71-00)
      String randomDigitAssignment;
      if (rangeEnd == 100) {
        randomDigitAssignment = '${rangeStart.toString().padLeft(2, '0')}-00';
      } else {
        randomDigitAssignment =
            '${rangeStart.toString().padLeft(2, '0')}-${rangeEnd.toString().padLeft(2, '0')}';
      }

      entries.add(
        DayTypeEntry(
          dayType: dayType,
          probability: probability,
          cumulativeProbability: cumulative,
          randomDigitAssignment: randomDigitAssignment,
        ),
      );
    });

    return entries;
  }

  // Fixed demand distributions from the problem
  static final Map<String, List<DemandEntry>> demandDistributions = {
    'High': _calculateHighDemand(),
    'Medium': _calculateMediumDemand(),
    'Low': _calculateLowDemand(),
  };

  static List<DemandEntry> _calculateHighDemand() {
    final Map<int, double> probs = {
      50: 0.05,
      60: 0.07,
      70: 0.10,
      80: 0.20,
      90: 0.30,
      100: 0.15,
      110: 0.13,
    };
    return _convertToEntries(probs);
  }

  static List<DemandEntry> _calculateMediumDemand() {
    final Map<int, double> probs = {
      50: 0.12,
      60: 0.16,
      70: 0.30,
      80: 0.20,
      90: 0.08,
      100: 0.06,
      110: 0.08,
    };
    return _convertToEntries(probs);
  }

  static List<DemandEntry> _calculateLowDemand() {
    final Map<int, double> probs = {
      50: 0.30,
      60: 0.20,
      70: 0.06,
      80: 0.12,
      90: 0.13,
      100: 0.09,
      110: 0.10,
    };
    return _convertToEntries(probs);
  }

  static List<DemandEntry> _convertToEntries(Map<int, double> probs) {
    List<DemandEntry> entries = [];
    double cumulative = 0.0;

    probs.forEach((demand, probability) {
      double previousCumulative = cumulative;
      cumulative += probability;

      // Calculate random digit assignment using ma'am's method
      int rangeStart = (previousCumulative * 100).round() + 1;
      int rangeEnd = (cumulative * 100).round();

      // Handle the wrap-around case (e.g., 99-00)
      String randomDigitAssignment;
      if (rangeEnd == 100) {
        randomDigitAssignment = '${rangeStart.toString().padLeft(2, '0')}-00';
      } else if (rangeStart == rangeEnd) {
        randomDigitAssignment = rangeStart.toString().padLeft(2, '0');
      } else {
        randomDigitAssignment =
            '${rangeStart.toString().padLeft(2, '0')}-${rangeEnd.toString().padLeft(2, '0')}';
      }

      entries.add(
        DemandEntry(
          demand: demand,
          probability: probability,
          cumulativeProbability: cumulative,
          randomDigitAssignment: randomDigitAssignment,
        ),
      );
    });

    return entries;
  }

  // Helper method to get demand based on random number (for simulation)
  static int getDemandFromRandom(String dayType, double random) {
    final entries = demandDistributions[dayType]!;
    for (var entry in entries) {
      if (random <= entry.cumulativeProbability) {
        return entry.demand;
      }
    }
    return entries.last.demand;
  }

  // Generate random digit simulation for specified number of days
  static List<DaySimulationEntry> generateRandomDigitSimulation(int numDays) {
    final random = Random();
    List<DaySimulationEntry> entries = [];

    for (int day = 1; day <= numDays; day++) {
      // Generate random digit (1-100, display as 01-00)
      int randomDigitForDayType = random.nextInt(100) + 1;
      if (randomDigitForDayType == 100) randomDigitForDayType = 0;

      // Determine day type based on random digit
      String dayType = _getDayTypeFromRandomDigit(randomDigitForDayType);

      // Generate random digit for demand (1-100, display as 01-00)
      int randomDigitForDemand = random.nextInt(100) + 1;
      if (randomDigitForDemand == 100) randomDigitForDemand = 0;

      // Determine demand based on random digit and day type
      int demand = _getDemandFromRandomDigit(randomDigitForDemand, dayType);

      entries.add(
        DaySimulationEntry(
          dayNumber: day,
          randomDigitForDayType: randomDigitForDayType,
          dayType: dayType,
          randomDigitForDemand: randomDigitForDemand,
          demand: demand,
        ),
      );
    }

    return entries;
  }

  static String _getDayTypeFromRandomDigit(int randomDigit) {
    final dayTypeEntries = getDayTypeProbabilities();

    for (var entry in dayTypeEntries) {
      final parts = entry.randomDigitAssignment.split('-');
      int start = int.parse(parts[0]);
      int end = parts[1] == '00' ? 100 : int.parse(parts[1]);

      // Handle wrap-around case (e.g., 71-00 means 71-100)
      if (parts[1] == '00') {
        if (randomDigit >= start || randomDigit == 0) {
          return entry.dayType;
        }
      } else {
        if (randomDigit >= start && randomDigit <= end) {
          return entry.dayType;
        }
      }
    }

    return 'Low'; // Fallback
  }

  static int _getDemandFromRandomDigit(int randomDigit, String dayType) {
    final demandEntries = demandDistributions[dayType]!;

    for (var entry in demandEntries) {
      final parts = entry.randomDigitAssignment.split('-');
      int start = int.parse(parts[0]);
      int end = parts[1] == '00' ? 100 : int.parse(parts[1]);

      // Handle wrap-around case
      if (parts[1] == '00') {
        if (randomDigit >= start || randomDigit == 0) {
          return entry.demand;
        }
      } else {
        if (randomDigit >= start && randomDigit <= end) {
          return entry.demand;
        }
      }
    }

    return 50; // Fallback
  }
}
