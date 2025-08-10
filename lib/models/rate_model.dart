class RateModel{
  final String date;
  final String baseCurrency;
  Map<String, dynamic> rates;
  RateModel({required this.date, required this.baseCurrency, required this.rates});
  factory RateModel.fromJson(Map<String,dynamic> json){
    String baseCurrency = json.keys.firstWhere((key)=> key !='date');
    Map<String, dynamic> rates =json[baseCurrency];
    return RateModel(date: json['date'], baseCurrency: baseCurrency, rates: rates,);
  }
}