import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/currency_view_model.dart';
import '../utils/validators.dart';

class CurrencyView extends StatefulWidget {
  const CurrencyView({Key? key}) : super(key: key);

  @override
  State<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<CurrencyViewModel>(context, listen: false);
      vm.loadCurrencies().then((_) {
        vm.fromCurrency = "usd";
        vm.toCurrency = "vnd";
        vm.notifyListeners();
      });
    });
  }


  Future<void> _showCurrencyPicker(
      BuildContext context, bool isFrom, CurrencyViewModel vm) async {
    String query = '';
    List currencyList = vm.currencies;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateModal) {
          final filtered = currencyList.where((c) {
            if (query.isEmpty) return true;
            final q = query.toLowerCase();
            return c.code!.toLowerCase().contains(q) ||
                c.name.toLowerCase().contains(q);
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: 420,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search currency (code or name)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setStateModal(() => query = v),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return ListTile(
                          title: Text('${c.code!.toUpperCase()} — ${c.name}'),
                          onTap: () {
                            if (isFrom) {
                              vm.fromCurrency = c.code;
                            } else {
                              vm.toCurrency = c.code;
                            }
                            vm.notifyListeners();
                            Navigator.of(ctx).pop();
                            if (_amountController.text.trim().isNotEmpty) {
                              vm.amount = double.tryParse(
                                  _amountController.text.replaceAll(',', '')) ??
                                  0;
                              vm.convert();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CurrencyViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: vm.isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.indigo),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Currency Converter",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showCurrencyPicker(context, true, vm),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "From",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          vm.fromCurrency?.toUpperCase() ?? "Select",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: (){ if (_formKey.currentState!.validate())
                      vm.swapCurrencies();},
                    icon: const Icon(Icons.swap_horiz,
                        color: Colors.indigo, size: 28),
                    tooltip: "Swap currencies",
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showCurrencyPicker(context, false, vm),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "To",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          vm.toCurrency?.toUpperCase() ?? "Select",
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              /// Row amount + result
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Amount",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                        ),
                        // validator: validateAmount,
                        onChanged: (val) {
                          vm.amount = double.tryParse(val) ?? 0;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 55),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: vm.result != null
                            ? Text(
                          NumberFormat("#,##0.00", "en_US").format(vm.result),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )
                            : const Text(
                          "-",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15)),
                  onPressed: () {(_formKey.currentState!.validate()&& validateAmount(_amountController.text)== null) ? vm.convertCurrency(_amountController.text): ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:Text("Please enter valid amount!"),
                    backgroundColor: Colors.red,
                    ));},
                  child: const Text("Convert"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
