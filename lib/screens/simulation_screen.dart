import 'dart:math';
import 'package:flutter/material.dart';
import '../models/day_result.dart';
import '../models/simulation_parameters.dart';
import '../models/demand_distribution.dart';
import '../models/day_simulation_entry.dart';
import '../widgets/parameter_input_dialog.dart';
import '../widgets/demand_distribution_table.dart';
import '../widgets/day_type_probability_table.dart';
import '../widgets/random_digit_simulation_table.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  SimulationParameters? parameters;
  List<DayResult> simulationResults = [];
  List<DaySimulationEntry> randomDigitSimulation = [];
  bool isSimulating = false;

  void _showParameterDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ParameterInputDialog(
        currentParameters: parameters,
        onParametersSet: (params) {
          setState(() {
            parameters = params;
            simulationResults.clear();
          });
        },
      ),
    );
  }

  void _runSimulation() {
    if (parameters == null) {
      _showErrorDialog('Please set simulation parameters first');
      return;
    }

    setState(() {
      isSimulating = true;
    });

    // Run simulation in next frame to show loading indicator
    Future.delayed(const Duration(milliseconds: 100), () {
      // Generate random digit simulation
      final randomDigitEntries =
          DemandDistribution.generateRandomDigitSimulation(
            parameters!.simulationDays,
          );

      // Use the random digit simulation data to calculate daily results
      final results = _calculateDailyResults(randomDigitEntries, parameters!);

      setState(() {
        randomDigitSimulation = randomDigitEntries;
        simulationResults = results;
        isSimulating = false;
      });
    });
  }

  List<DayResult> _calculateDailyResults(
    List<DaySimulationEntry> randomDigitEntries,
    SimulationParameters params,
  ) {
    List<DayResult> results = [];

    for (var entry in randomDigitEntries) {
      // Use the day type and demand from random digit simulation
      int newspapersSold = min(params.stockLevel, entry.demand);
      int excessDemand = max(0, entry.demand - params.stockLevel);
      int remainingNewspapers = max(0, params.stockLevel - entry.demand);

      // Total Revenue = Selling Price × Sold Newspapers
      double totalRevenue = newspapersSold * params.sellingPrice;

      // Lost Profit = Excess Demand × Lost Profit per Unmet
      double lostProfit = excessDemand * params.lostProfitPerBook;

      // Scrap Value = Scrap Price × Remaining Newspapers
      double scrapValue = remainingNewspapers * params.scrapPrice;

      // Total Cost = Cost Price × Stock Level
      double totalCost = params.stockLevel * params.costPrice;

      // Daily Profit = Revenue - Lost Profit + Scrap - Cost
      double dailyProfit = totalRevenue - lostProfit + scrapValue - totalCost;

      results.add(
        DayResult(
          day: entry.dayNumber,
          dayType: entry.dayType,
          demand: entry.demand,
          totalRevenue: totalRevenue,
          lostProfit: lostProfit,
          scrapValue: scrapValue,
          dailyProfit: dailyProfit,
        ),
      );
    }

    return results;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Newspaper Inventory Simulation'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configure Parameters',
            onPressed: _showParameterDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (parameters == null) _buildWelcomeCard(),
              if (parameters != null) _buildCurrentParametersCard(),
              if (parameters != null) const SizedBox(height: 20),
              if (parameters != null) _buildSimulationButton(),
              const SizedBox(height: 20),
              _buildDemandDistributionsSection(),
              const SizedBox(height: 20),
              if (simulationResults.isNotEmpty) ...[
                _buildSummaryCard(),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // If screen width is less than 1200px, stack vertically
                    if (constraints.maxWidth < 1200) {
                      return Column(
                        children: [
                          if (randomDigitSimulation.isNotEmpty)
                            RandomDigitSimulationTable(
                              entries: randomDigitSimulation,
                            ),
                          if (randomDigitSimulation.isNotEmpty)
                            const SizedBox(height: 20),
                          _buildResultsTable(),
                        ],
                      );
                    } else {
                      // Desktop: Random Digit (left, 40%) and Daily Results (right, 60%)
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (randomDigitSimulation.isNotEmpty)
                            Expanded(
                              flex: 4,
                              child: RandomDigitSimulationTable(
                                entries: randomDigitSimulation,
                              ),
                            ),
                          if (randomDigitSimulation.isNotEmpty)
                            const SizedBox(width: 20),
                          Expanded(flex: 6, child: _buildResultsTable()),
                        ],
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.newspaper, size: 64, color: Colors.black),
            const SizedBox(height: 16),
            Text(
              'Welcome to Newspaper Simulation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Configure your simulation parameters to begin',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showParameterDialog,
              icon: const Icon(Icons.settings),
              label: const Text('Set Parameters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentParametersCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Parameters',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Parameters',
                  onPressed: _showParameterDialog,
                  color: Colors.black,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Cost Price:',
              '\$${parameters!.costPrice.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Selling Price:',
              '\$${parameters!.sellingPrice.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Scrap/Return Price:',
              '\$${parameters!.scrapPrice.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Lost Profit per Unmet:',
              '\$${parameters!.lostProfitPerBook.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Daily Stock Level:',
              '${parameters!.stockLevel} newspapers',
            ),
            _buildInfoRow(
              'Simulation Days:',
              '${parameters!.simulationDays} days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemandDistributionsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: Colors.black),
                const SizedBox(width: 12),
                Text(
                  'Probability Distribution Tables',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Day Type Probability Table (centered)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 2000),
                child: DayTypeProbabilityTable(),
              ),
            ),
            const SizedBox(height: 24),
            // Demand Distribution Tables Title
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  'Demand Distribution by Day Type',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // If screen width is less than 800px, stack vertically (mobile)
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: [
                      DemandDistributionTable(dayType: 'High'),
                      SizedBox(height: 16),
                      DemandDistributionTable(dayType: 'Medium'),
                      SizedBox(height: 16),
                      DemandDistributionTable(dayType: 'Low'),
                    ],
                  );
                } else {
                  // Desktop/tablet: side by side with centered spacing
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: DemandDistributionTable(dayType: 'High'),
                        ),
                      ),
                      SizedBox(width: 24),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: DemandDistributionTable(dayType: 'Medium'),
                        ),
                      ),
                      SizedBox(width: 24),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: DemandDistributionTable(dayType: 'Low'),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSimulationButton() {
    return ElevatedButton.icon(
      onPressed: isSimulating ? null : _runSimulation,
      icon: isSimulating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.play_arrow),
      label: Text(isSimulating ? 'Running Simulation...' : 'Run Simulation'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildSummaryCard() {
    double totalProfit = simulationResults.fold(
      0.0,
      (sum, r) => sum + r.dailyProfit,
    );
    double avgDailyProfit = totalProfit / simulationResults.length;

    double totalRevenue = simulationResults.fold(
      0.0,
      (sum, r) => sum + r.totalRevenue,
    );

    double totalLostProfit = simulationResults.fold(
      0.0,
      (sum, r) => sum + r.lostProfit,
    );

    double totalScrapValue = simulationResults.fold(
      0.0,
      (sum, r) => sum + r.scrapValue,
    );

    // Calculate optimal stock level based on simulation results
    int optimalStockLevel = _calculateOptimalStockLevel();

    return Card(
      elevation: 4,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulation Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total Profit:',
              '\$${totalProfit.toStringAsFixed(2)}',
              totalProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
            ),
            _buildSummaryRow(
              'Average Daily Profit:',
              '\$${avgDailyProfit.toStringAsFixed(2)}',
              avgDailyProfit >= 0 ? Colors.green.shade600 : Colors.red.shade600,
            ),
            _buildSummaryRow(
              'Total Revenue:',
              '\$${totalRevenue.toStringAsFixed(2)}',
              Colors.green.shade700,
            ),
            _buildSummaryRow(
              'Total Lost Profit:',
              '\$${totalLostProfit.toStringAsFixed(2)}',
              Colors.red.shade700,
            ),
            _buildSummaryRow(
              'Total Scrap Value:',
              '\$${totalScrapValue.toStringAsFixed(2)}',
              Colors.blue.shade700,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Optimal Stock Recommendation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade900,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Based on this simulation, the optimal stock level to maximize profit and minimize losses would be:',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended Daily Stock:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$optimalStockLevel newspapers',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (optimalStockLevel != parameters!.stockLevel) ...[
                    const SizedBox(height: 8),
                    Text(
                      optimalStockLevel > parameters!.stockLevel
                          ? '↑ Increase stock by ${optimalStockLevel - parameters!.stockLevel} to capture unmet demand'
                          : '↓ Decrease stock by ${parameters!.stockLevel - optimalStockLevel} to reduce waste',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateOptimalStockLevel() {
    // Count frequency of each demand level
    Map<int, int> demandFrequency = {};
    for (var entry in randomDigitSimulation) {
      demandFrequency[entry.demand] = (demandFrequency[entry.demand] ?? 0) + 1;
    }

    // Calculate profit for different stock levels
    Map<int, double> profitByStockLevel = {};

    // Get unique demand values and test stock levels around the average
    List<int> uniqueDemands = demandFrequency.keys.toList()..sort();
    int minStock = uniqueDemands.first;
    int maxStock = uniqueDemands.last;

    for (int stockLevel = minStock; stockLevel <= maxStock; stockLevel += 10) {
      double totalProfit = 0.0;

      for (var entry in randomDigitSimulation) {
        int newspapersSold = min(stockLevel, entry.demand);
        int excessDemand = max(0, entry.demand - stockLevel);
        int remainingNewspapers = max(0, stockLevel - entry.demand);

        double revenue = newspapersSold * parameters!.sellingPrice;
        double lostProfit = excessDemand * parameters!.lostProfitPerBook;
        double scrapValue = remainingNewspapers * parameters!.scrapPrice;
        double cost = stockLevel * parameters!.costPrice;

        totalProfit += (revenue - lostProfit + scrapValue - cost);
      }

      profitByStockLevel[stockLevel] = totalProfit;
    }

    // Find stock level with maximum profit
    int optimalStock = minStock;
    double maxProfit = profitByStockLevel[minStock]!;

    profitByStockLevel.forEach((stock, profit) {
      if (profit > maxProfit) {
        maxProfit = profit;
        optimalStock = stock;
      }
    });

    return optimalStock;
  }

  Widget _buildResultsTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Simulation Results',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Using news day type and demand to calculate daily profit.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 13),
            DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
              columnSpacing: 90,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 48,
              columns: const [
                DataColumn(
                  label: Text(
                    'Day',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Type of\nNews Day',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Demand',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total\nRevenue',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Lost\nProfit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Scrap\nValue',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Daily\nProfit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              rows: simulationResults.map((result) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        result.day.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        result.dayType,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getColorForDayType(result.dayType),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        result.demand.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '\$${result.totalRevenue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '\$${result.lostProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '\$${result.scrapValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '\$${result.dailyProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: result.dailyProfit >= 0
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForDayType(String dayType) {
    switch (dayType) {
      case 'High':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
