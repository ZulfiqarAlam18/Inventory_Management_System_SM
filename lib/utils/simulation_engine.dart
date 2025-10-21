import 'dart:math';
import '../models/day_result.dart';
import '../models/simulation_parameters.dart';
import '../models/demand_distribution.dart';

class SimulationEngine {
  static List<DayResult> runSimulation(SimulationParameters params) {
    List<DayResult> results = [];
    final random = Random();

    for (int day = 1; day <= params.simulationDays; day++) {
      // Step 1: Determine day type
      String dayType = _selectDayType(random);

      // Step 2: Determine actual demand based on day type
      int demand = DemandDistribution.getDemandFromRandom(
        dayType,
        random.nextDouble(),
      );

      // Step 3: Calculate financial metrics
      int newspapersSold = min(params.stockLevel, demand);
      int excessDemand = max(0, demand - params.stockLevel);
      int remainingNewspapers = max(0, params.stockLevel - demand);

      // Total Revenue = Selling Price × Sold Newspapers
      double totalRevenue = newspapersSold * params.sellingPrice;

      // Lost Profit = Excess Demand × Lost Profit per Unmet Newspaper
      double lostProfit = excessDemand * params.lostProfitPerBook;

      // Scrap Value = Scrap Price × Remaining Newspapers
      double scrapValue = remainingNewspapers * params.scrapPrice;

      // Total Cost = Cost Price × Stock Level
      double totalCost = params.stockLevel * params.costPrice;

      // Daily Profit = Revenue - Lost Profit + Scrap - Cost
      double dailyProfit = totalRevenue - lostProfit + scrapValue - totalCost;

      results.add(
        DayResult(
          day: day,
          dayType: dayType,
          demand: demand,
          totalRevenue: totalRevenue,
          lostProfit: lostProfit,
          scrapValue: scrapValue,
          dailyProfit: dailyProfit,
        ),
      );
    }

    return results;
  }

  static String _selectDayType(Random random) {
    double rand = random.nextDouble();
    double cumulative = 0.0;

    for (var entry in DemandDistribution.dayTypeProbabilities.entries) {
      cumulative += entry.value;
      if (rand <= cumulative) {
        return entry.key;
      }
    }
    return 'Low'; // Fallback
  }
}
