class CurrencyModel {
  final String code;
  final String name;

  CurrencyModel({required this.code, required this.name});

   factory CurrencyModel.fromJson(MapEntry<String, dynamic> json){
     return CurrencyModel (code: json.key, name: json.value,);
   }
}