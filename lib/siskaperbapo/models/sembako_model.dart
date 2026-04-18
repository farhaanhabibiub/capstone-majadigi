class CityPrice {
  final String city;
  final int price;
  CityPrice(this.city, this.price);
}

class SembakoItem {
  final String id;
  final String name;
  final int price;
  final int status;
  final String statusText;
  final String imagePath;
  final List<int> historyPrices;
  final List<String> historyDates;
  final List<CityPrice> cityPrices;

  SembakoItem({
    required this.id,
    required this.name,
    required this.price,
    required this.status,
    required this.statusText,
    required this.imagePath,
    required this.historyPrices,
    required this.historyDates,
    required this.cityPrices,
  });
}
