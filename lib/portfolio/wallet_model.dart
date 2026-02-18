// ================= SAFE DOUBLE PARSER =================
double parseDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

// ================= ROOT RESPONSE =================
class DashboardWalletResponse {
  final bool success;
  final DashboardData data;
  final String message;

  DashboardWalletResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory DashboardWalletResponse.fromJson(Map<String, dynamic> json) {
    return DashboardWalletResponse(
      success: json['success'] ?? false,
      data: DashboardData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}

// ================= DASHBOARD DATA =================
class DashboardData {
  final UserModel user;
  final PortfolioModel portfolio;
  final List<CoinModel> coins;
  final List<TransactionModel> recentTransactions;

  DashboardData({
    required this.user,
    required this.portfolio,
    required this.coins,
    required this.recentTransactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: UserModel.fromJson(json['user']),
      portfolio: PortfolioModel.fromJson(json['portfolio']),
      coins: (json['coins'] as List).map((e) => CoinModel.fromJson(e)).toList(),
      recentTransactions: (json['recent_transactions'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
    );
  }
}

// ================= USER =================
class UserModel {
  final int id;
  final String name;
  final String email;
  final BalanceModel balances;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.balances,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      balances: BalanceModel.fromJson(json['balances']),
    );
  }
}

// ================= BALANCES =================
class BalanceModel {
  final double inrBalance;
  final double utilizedBalance;
  final double unutilizedBalance;
  final double totalBalance;

  BalanceModel({
    required this.inrBalance,
    required this.utilizedBalance,
    required this.unutilizedBalance,
    required this.totalBalance,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      inrBalance: parseDouble(json['inr_balance']),
      utilizedBalance: parseDouble(json['utilized_balance']),
      unutilizedBalance: parseDouble(json['unutilized_balance']),
      totalBalance: parseDouble(json['total_balance']),
    );
  }
}

// ================= PORTFOLIO =================
class PortfolioModel {
  final double totalBalance;
  final double coinHoldingsValue;
  final double totalInvested;
  final double profitLoss;
  final double profitLossPercent;
  final List<HoldingModel> holdings;

  PortfolioModel({
    required this.totalBalance,
    required this.coinHoldingsValue,
    required this.totalInvested,
    required this.profitLoss,
    required this.profitLossPercent,
    required this.holdings,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      totalBalance: parseDouble(json['total_balance']),
      coinHoldingsValue: parseDouble(json['coin_holdings_value']),
      totalInvested: parseDouble(json['total_invested']),
      profitLoss: parseDouble(json['total_profit_loss']),
      profitLossPercent: parseDouble(json['total_profit_loss_percentage']),
      holdings: (json['holdings'] as List)
          .map((e) => HoldingModel.fromJson(e))
          .toList(),
    );
  }
}

// ================= HOLDINGS =================
class HoldingModel {
  final CoinShortModel coin;
  final double balance;
  final double investedValue;
  final double currentValue;
  final double pnl;
  final double pnlPercentage;

  HoldingModel({
    required this.coin,
    required this.balance,
    required this.investedValue,
    required this.currentValue,
    required this.pnl,
    required this.pnlPercentage,
  });

  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      coin: CoinShortModel.fromJson(json['coin']),
      balance: parseDouble(json['balance']),
      investedValue: parseDouble(json['invested_value']),
      currentValue: parseDouble(json['current_value']),
      pnl: parseDouble(json['pnl']),
      pnlPercentage: parseDouble(json['pnl_percentage']),
    );
  }
}

// ================= COIN SHORT =================
class CoinShortModel {
  final int id;
  final String name;
  final String symbol;
  final String image;

  CoinShortModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
  });

  factory CoinShortModel.fromJson(Map<String, dynamic> json) {
    return CoinShortModel(
      id: json['id'],
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

// ================= COIN =================
class CoinModel {
  final int id;
  final String name;
  final String symbol;
  final String image;
  final double price;

  CoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.price,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'],
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      image: json['image'] ?? '',
      price: parseDouble(json['price']),
    );
  }
}

// ================= TRANSACTION =================
class TransactionModel {
  final int id;
  final String type;
  final double amountInr;
  final String status;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amountInr,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'] ?? '',
      amountInr: parseDouble(json['amount_inr']),
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
