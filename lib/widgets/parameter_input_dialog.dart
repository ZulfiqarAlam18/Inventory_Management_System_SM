import 'package:flutter/material.dart';
import '../models/simulation_parameters.dart';

class ParameterInputDialog extends StatefulWidget {
  final SimulationParameters? currentParameters;
  final Function(SimulationParameters) onParametersSet;

  const ParameterInputDialog({
    super.key,
    this.currentParameters,
    required this.onParametersSet,
  });

  @override
  State<ParameterInputDialog> createState() => _ParameterInputDialogState();
}

class _ParameterInputDialogState extends State<ParameterInputDialog> {
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _scrapPriceController;
  late TextEditingController _lostProfitController;
  late TextEditingController _stockLevelController;
  late TextEditingController _simulationDaysController;

  @override
  void initState() {
    super.initState();
    final params = widget.currentParameters;
    _costPriceController = TextEditingController(
      text: params?.costPrice.toString() ?? '15',
    );
    _sellingPriceController = TextEditingController(
      text: params?.sellingPrice.toString() ?? '25',
    );
    _scrapPriceController = TextEditingController(
      text: params?.scrapPrice.toString() ?? '5',
    );
    _lostProfitController = TextEditingController(
      text: params?.lostProfitPerBook.toString() ?? '10',
    );
    _stockLevelController = TextEditingController(
      text: params?.stockLevel.toString() ?? '90',
    );
    _simulationDaysController = TextEditingController(
      text: params?.simulationDays.toString() ?? '20',
    );
  }

  @override
  void dispose() {
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _scrapPriceController.dispose();
    _lostProfitController.dispose();
    _stockLevelController.dispose();
    _simulationDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.settings, color: Colors.black),
          const SizedBox(width: 12),
          const Text('Simulation Parameters'),
        ],
      ),
      content: SizedBox(
        width: 500, // Increased width for better spacing
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildParameterField(
                controller: _costPriceController,
                label: 'Cost Price per Newspaper',
                icon: Icons.attach_money,
                prefix: '\$',
              ),
              const SizedBox(height: 12),
              _buildParameterField(
                controller: _sellingPriceController,
                label: 'Selling Price per Newspaper',
                icon: Icons.sell,
                prefix: '\$',
              ),
              const SizedBox(height: 12),
              _buildParameterField(
                controller: _scrapPriceController,
                label: 'Unsold/Scrap Price per Newspaper',
                icon: Icons.delete_outline,
                prefix: '\$',
              ),
              const SizedBox(height: 12),
              _buildParameterField(
                controller: _lostProfitController,
                label: 'Lost Profit per Unmet Demand',
                icon: Icons.money_off,
                prefix: '\$',
              ),
              const SizedBox(height: 12),
              _buildParameterField(
                controller: _stockLevelController,
                label: 'Bundles of Newspapers Bought Daily',
                icon: Icons.inventory,
                prefix: '',
              ),
              const SizedBox(height: 12),
              _buildParameterField(
                controller: _simulationDaysController,
                label: 'Simulation Cycles (Days)',
                icon: Icons.calendar_today,
                prefix: '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validateAndSetParameters,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text('Set Parameters'),
        ),
      ],
    );
  }

  Widget _buildParameterField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefix.isEmpty ? null : prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  void _validateAndSetParameters() {
    final double? parsedCostPrice = double.tryParse(_costPriceController.text);
    final double? parsedSellingPrice = double.tryParse(
      _sellingPriceController.text,
    );
    final double? parsedScrapPrice = double.tryParse(
      _scrapPriceController.text,
    );
    final double? parsedLostProfit = double.tryParse(
      _lostProfitController.text,
    );
    final int? parsedStockLevel = int.tryParse(_stockLevelController.text);
    final int? parsedDays = int.tryParse(_simulationDaysController.text);

    if (parsedCostPrice == null || parsedCostPrice <= 0) {
      _showErrorDialog('Please enter a valid cost price (positive number)');
      return;
    }

    if (parsedSellingPrice == null || parsedSellingPrice <= parsedCostPrice) {
      _showErrorDialog('Selling price must be greater than cost price');
      return;
    }

    if (parsedScrapPrice == null || parsedScrapPrice < 0) {
      _showErrorDialog('Please enter a valid scrap price (non-negative)');
      return;
    }

    if (parsedLostProfit == null || parsedLostProfit < 0) {
      _showErrorDialog('Please enter a valid lost profit (non-negative)');
      return;
    }

    if (parsedStockLevel == null || parsedStockLevel <= 0) {
      _showErrorDialog('Please enter a valid stock level (positive number)');
      return;
    }

    if (parsedDays == null || parsedDays <= 0) {
      _showErrorDialog('Please enter a valid number of days (positive number)');
      return;
    }

    final parameters = SimulationParameters(
      costPrice: parsedCostPrice,
      sellingPrice: parsedSellingPrice,
      scrapPrice: parsedScrapPrice,
      lostProfitPerBook: parsedLostProfit,
      stockLevel: parsedStockLevel,
      simulationDays: parsedDays,
    );

    Navigator.pop(context);
    widget.onParametersSet(parameters);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.black),
            SizedBox(width: 12),
            Text('Invalid Input'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
