class DashboardModel {
  final UserModel user;
  final List<CoinModel> coins;

  DashboardModel({
    required this.user,
    required this.coins,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      user: UserModel.fromJson(json["user"]),
      coins: (json["coins"] as List)
          .map((coin) => CoinModel.fromJson(coin))
          .toList(),
    );
  }

  Map<String, dynamic>? operator [](String other) {}
}

//////////////////////////////////////////////////////////////
// USER MODEL
//////////////////////////////////////////////////////////////

class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
    );
  }
}

//////////////////////////////////////////////////////////////
// COIN MODEL
//////////////////////////////////////////////////////////////

class CoinModel {
  final int id;
  final String name;
  final String symbol;
  final String image;
  final double price;
  final double serviceCharge;
  final double gstCharges;

  CoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.price,
    required this.serviceCharge,
    required this.gstCharges,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json["id"],
      name: json["name"],
      symbol: json["symbol"],
      image: json["image"],
      price: (json["price"] as num).toDouble(),
      serviceCharge: (json["service_charge"] as num).toDouble(),
      gstCharges: (json["gst_charges"] as num).toDouble(),
    );
  }
}