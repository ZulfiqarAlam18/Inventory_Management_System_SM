class SimulationParameters {
  final double costPrice;
  final double sellingPrice;
  final double scrapPrice;
  final double lostProfitPerBook;
  final int stockLevel;
  final int simulationDays;

  SimulationParameters({
    required this.costPrice,
    required this.sellingPrice,
    required this.scrapPrice,
    required this.lostProfitPerBook,
    required this.stockLevel,
    required this.simulationDays,
  });

  double get profitPerSale => sellingPrice - costPrice;
  double get lossPerUnsold => costPrice - scrapPrice;
}
