double parseDouble(dynamic v) =>
    v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

class PortfolioModel {
  final double totalBalance;
  final double coinHoldingsValue;
  final double totalInvested;
  final double profitLoss;
  final double profitLossPercent;

  PortfolioModel({
    required this.totalBalance,
    required this.coinHoldingsValue,
    required this.totalInvested,
    required this.profitLoss,
    required this.profitLossPercent,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      totalBalance: parseDouble(json["total_balance"]),
      coinHoldingsValue: parseDouble(json["coin_holdings_value"]),
      totalInvested: parseDouble(json["total_invested"]),
      profitLoss: parseDouble(json["total_profit_loss"]),
      profitLossPercent: parseDouble(json["total_profit_loss_percentage"]),
    );
  }
}
