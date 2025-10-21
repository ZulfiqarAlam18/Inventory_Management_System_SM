class DayResult {
  final int day;
  final String dayType;
  final int demand;
  final double totalRevenue;
  final double lostProfit;
  final double scrapValue;
  final double dailyProfit;

  DayResult({
    required this.day,
    required this.dayType,
    required this.demand,
    required this.totalRevenue,
    required this.lostProfit,
    required this.scrapValue,
    required this.dailyProfit,
  });
}
