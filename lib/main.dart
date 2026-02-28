import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // อย่าลืมลงแพ็กเกจนี้เพื่อใส่คอมมาในตัวเลข

void main() => runApp(const GamePriceApp());

class GamePriceApp extends StatelessWidget {
  const GamePriceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const PriceCalculator(),
    );
  }
}

class PriceCalculator extends StatefulWidget {
  const PriceCalculator({super.key});
  @override
  State<PriceCalculator> createState() => _PriceCalculatorState();
}

class _PriceCalculatorState extends State<PriceCalculator> {
  final TextEditingController _controller = TextEditingController();
  double _shadowPrice = 0;
  final NumberFormat _formatter = NumberFormat('#,###'); // สำหรับแสดงคอมมา

  // ฟังก์ชันสำหรับเพิ่มคอมมาในช่องระบุราคา
  String _formatNumberWithComma(String value) {
    if (value.isEmpty) return '';
    final numericValue = value.replaceAll(',', '');
    if (numericValue.isEmpty) return '';
    final formatted = _formatter.format(int.parse(numericValue));
    return formatted;
  }

  // ฟังก์ชันคำนวณราคาตามตาราง (ราคา = Base + Cost หรือ (Base * Multiplier) + Cost หรือ (Base / Divisor) + Cost)
  String calculatePrice(double value, String operator, double cost) {
    double result = 0;
    if (operator == '+') {
      result = _shadowPrice + cost; // สูตรบวกปกติ
    } else if (operator == '*') {
      result = (_shadowPrice * value) + cost; // สูตรคูณปกติ
    } else if (operator == '/') {
      result = (_shadowPrice / value) + cost; // สูตรหาร
    }

    return _formatter.format(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shadowdecon Price Converter')),
      body: SingleChildScrollView(
        // ป้องกันหน้าจอล้นเวลาเปิดคีย์บอร์ด
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final formatted = _formatNumberWithComma(newValue.text);
                  return newValue.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }),
              ],
              decoration: const InputDecoration(
                labelText: 'ระบุราคา Shadowdecon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on, color: Colors.amber),
              ),
              onChanged: (value) {
                setState(() {
                  final numericValue = value.replaceAll(',', '');
                  _shadowPrice = double.tryParse(numericValue) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildPriceRow(
              'Enhancement Stone (Low Grade)',
              'Stone (Low Grade)',
              calculatePrice(_shadowPrice, "+", 20000),
              Colors.blue[50]!,
            ),
            _buildPriceRow(
              'Enhancement Ore (Low Grade)',
              'Ore (Low Grade)',
              _formatter.format(((_shadowPrice + 20000) - 10000) / 5),
              Colors.blue[50]!,
            ), // สูตร: ((_shadowPrice+20000)-10000)/5
            _buildPriceRow(
              'Enhancement Stone (Medium Grade)',
              'Stone (Medium Grade)',
              _formatter.format(((_shadowPrice + 20000) * 3) + 10000),
              Colors.purple[50]!,
            ), // สูตร: (Stone Low*3)+10000 = ((_shadowPrice+20000)*3)+10000
            _buildPriceRow(
              'Enhancement Ore (Medium Grade)',
              'Ore (Medium Grade)',
              _formatter.format((((_shadowPrice + 20000) * 3) - 10000) / 5),
              Colors.purple[50]!,
            ), // สูตร: (Stone Medium+10000)/5 = (((_shadowPrice+20000)*3)-10000)/5
            _buildPriceRow(
              'Stone (High Grade)',
              _formatter.format(
                ((((_shadowPrice + 20000) * 3) + 10000) * 3) + 20000,
              ),
              Colors.green[50]!,
            ), // สูตร: (Stone Medium*3)+20000
            _buildPriceRow(
              'Enhancement Ore (High Grade)',
              'Ore (High Grade)',
              _formatter.format(
                (((((_shadowPrice + 20000) * 3) + 10000) * 3) + 20000 - 50000) /
                    5,
              ),
              Colors.green[50]!,
            ), // สูตร: (Stone High-50000)/5
            _buildPriceRow(
              'Enhancement Stone (Supreme Grade)',
              'Stone (Supreme Grade)',
              _formatter.format(
                ((((((_shadowPrice + 20000) * 3) + 10000) * 3) + 20000) * 3) +
                    50000,
              ),
              Colors.red[50]!,
            ), // สูตร: (Stone High*3)+50000
            _buildPriceRow(
              'Enhancement Ore (Supreme Grade)',
              'Ore (Supreme Grade)',
              _formatter.format(
                (((((((_shadowPrice + 20000) * 3) + 10000) * 3) + 20000) * 3) +
                        50000 -
                        100000) /
                    5,
              ),
              Colors.red[50]!,
            ), // สูตร: (Stone Supreme-100000)/5
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างแถวแสดงราคาแต่ละไอเทม
  Widget _buildPriceRow(String label, String price, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
