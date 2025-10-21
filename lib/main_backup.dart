import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const BookstoreSimulationApp());
}

class BookstoreSimulationApp extends StatelessWidget {
  const BookstoreSimulationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookstore Inventory Simulation',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SimulationScreen(),
    );
  }
}

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  // Text controllers for user inputs
  final TextEditingController _stockLevelController = TextEditingController(
    text: '90',
  );
  final TextEditingController _simulationDaysController = TextEditingController(
    text: '20',
  );

  int stockLevel = 90; // Books stocked each day
  int simulationDays = 20;
  List<DayResult> simulationResults = [];
  double totalProfit = 0;
  bool isSimulating = false;

  // Fixed problem parameters (from Question 17)
  final Map<String, double> dayTypeProbabilities = {
    'High': 0.4,
    'Medium': 0.3,
    'Low': 0.3,
  };

  final Map<String, Map<int, double>> demandDistributions = {
    'High': {
      50: 0.05,
      60: 0.07,
      70: 0.10,
      80: 0.20,
      90: 0.30,
      100: 0.15,
      110: 0.13,
    },
    'Medium': {
      50: 0.12,
      60: 0.16,
      70: 0.30,
      80: 0.20,
      90: 0.08,
      100: 0.06,
      110: 0.08,
    },
    'Low': {
      50: 0.30,
      60: 0.20,
      70: 0.06,
      80: 0.12,
      90: 0.13,
      100: 0.09,
      110: 0.10,
    },
  };

  @override
  void dispose() {
    _stockLevelController.dispose();
    _simulationDaysController.dispose();
    super.dispose();
  }

  void runSimulation() {
    // Validate and parse inputs
    final int? parsedStockLevel = int.tryParse(_stockLevelController.text);
    final int? parsedDays = int.tryParse(_simulationDaysController.text);

    if (parsedStockLevel == null || parsedStockLevel <= 0) {
      _showErrorDialog('Please enter a valid stock level (positive number)');
      return;
    }

    if (parsedDays == null || parsedDays <= 0) {
      _showErrorDialog(
        'Please enter a valid number of simulation days (positive number)',
      );
      return;
    }

    setState(() {
      stockLevel = parsedStockLevel;
      simulationDays = parsedDays;
      isSimulating = true;
      simulationResults.clear();
      totalProfit = 0;
    });

    final random = Random();

    for (int day = 1; day <= simulationDays; day++) {
      // Step 1: Determine day type
      String dayType = selectDayType(random);

      // Step 2: Determine actual demand based on day type
      int demand = selectDemand(random, dayType);

      // Step 3: Calculate profit
      int booksSold = min(stockLevel, demand);
      int unsoldBooks = max(0, stockLevel - demand);
      int unmetDemand = max(0, demand - stockLevel);

      double profitFromSales = booksSold * 10.0; // $10 profit per book sold
      double lossFromUnsold = unsoldBooks * 10.0; // $10 loss per unsold book
      double lossFromUnmet = unmetDemand * 10.0; // $10 opportunity cost

      double dailyProfit = profitFromSales - lossFromUnsold - lossFromUnmet;
      totalProfit += dailyProfit;

      simulationResults.add(
        DayResult(
          day: day,
          dayType: dayType,
          demand: demand,
          booksSold: booksSold,
          unsoldBooks: unsoldBooks,
          unmetDemand: unmetDemand,
          dailyProfit: dailyProfit,
        ),
      );
    }

    setState(() {
      isSimulating = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Input'),
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

  String selectDayType(Random random) {
    double rand = random.nextDouble();
    double cumulative = 0.0;

    for (var entry in dayTypeProbabilities.entries) {
      cumulative += entry.value;
      if (rand <= cumulative) {
        return entry.key;
      }
    }
    return 'Low'; // Fallback
  }

  int selectDemand(Random random, String dayType) {
    double rand = random.nextDouble();
    double cumulative = 0.0;
    Map<int, double> distribution = demandDistributions[dayType]!;

    for (var entry in distribution.entries) {
      cumulative += entry.value;
      if (rand <= cumulative) {
        return entry.key;
      }
    }
    return 50; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookstore Inventory Simulation'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildInputCard(),
              const SizedBox(height: 20),
              _buildSimulationButton(),
              const SizedBox(height: 20),
              if (simulationResults.isNotEmpty) ...[
                _buildSummaryCard(),
                const SizedBox(height: 20),
                _buildResultsTable(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fixed Parameters (From Question 17)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Book Cost:', '\$15'),
            _buildInfoRow('Selling Price:', '\$25'),
            _buildInfoRow('Return Value:', '\$5'),
            _buildInfoRow('Opportunity Cost:', '\$10 per unmet demand'),
            const Divider(height: 24),
            Text(
              'Day Type Probabilities',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('High Demand:', '40%'),
            _buildInfoRow('Medium Demand:', '30%'),
            _buildInfoRow('Low Demand:', '30%'),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulation Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stockLevelController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Books Stocked Daily',
                hintText: 'Enter number of books to stock each day',
                prefixIcon: const Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _simulationDaysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Simulation Days',
                hintText: 'Enter number of days to simulate',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
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
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildSimulationButton() {
    return ElevatedButton.icon(
      onPressed: isSimulating ? null : runSimulation,
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
    double avgDailyProfit = totalProfit / simulationDays;
    int totalBooksSold = simulationResults.fold(
      0,
      (sum, r) => sum + r.booksSold,
    );
    int totalUnsold = simulationResults.fold(
      0,
      (sum, r) => sum + r.unsoldBooks,
    );
    int totalUnmet = simulationResults.fold(0, (sum, r) => sum + r.unmetDemand);

    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulation Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total Profit:',
              '\$${totalProfit.toStringAsFixed(2)}',
              Colors.green.shade700,
            ),
            _buildSummaryRow(
              'Average Daily Profit:',
              '\$${avgDailyProfit.toStringAsFixed(2)}',
              Colors.green.shade600,
            ),
            _buildSummaryRow(
              'Total Books Sold:',
              '$totalBooksSold books',
              Colors.blue.shade700,
            ),
            _buildSummaryRow(
              'Total Unsold:',
              '$totalUnsold books',
              Colors.orange.shade700,
            ),
            _buildSummaryRow(
              'Total Unmet Demand:',
              '$totalUnmet books',
              Colors.red.shade700,
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

  Widget _buildResultsTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Results',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.blue.shade100,
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Day',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Demand',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Sold',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Unsold',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Unmet',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Profit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: simulationResults.map((result) {
                  return DataRow(
                    cells: [
                      DataCell(Text(result.day.toString())),
                      DataCell(Text(result.dayType)),
                      DataCell(Text(result.demand.toString())),
                      DataCell(Text(result.booksSold.toString())),
                      DataCell(Text(result.unsoldBooks.toString())),
                      DataCell(Text(result.unmetDemand.toString())),
                      DataCell(
                        Text(
                          '\$${result.dailyProfit.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: result.dailyProfit >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DayResult {
  final int day;
  final String dayType;
  final int demand;
  final int booksSold;
  final int unsoldBooks;
  final int unmetDemand;
  final double dailyProfit;

  DayResult({
    required this.day,
    required this.dayType,
    required this.demand,
    required this.booksSold,
    required this.unsoldBooks,
    required this.unmetDemand,
    required this.dailyProfit,
  });
}
