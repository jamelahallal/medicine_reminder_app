import 'package:flutter/material.dart';
import 'medicineform.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _baseURL = 'medecine.atwebpages.com';

class Medicine {
  final int id;
  final String name;
  final List<bool> days;
  final int dosage;
  final String time;
  static const List<String> dayLetters = ["S", "M", "T", "W", "T", "F", "S"];

  Medicine(this.id,this.name, this.days, this.dosage,this.time);
}
List<Medicine> _medicines = [];
List<Medicine> get medicines => _medicines;

void getMedicines(Function(bool success) update, int userId) async {
  try {
    final url = Uri.http(
      _baseURL, 'getmedicine.php', {'user_id': '$userId'}, // send user_id like pid
    );

    final response = await http.get(url)
        .timeout(const Duration(seconds: 5));

    _medicines.clear();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      for (var row in jsonResponse) {
        List<bool> daysBool = List.filled(7, false);
        List<String> dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];

        for (var d in row['days'].split(',')) {
          int index = dayNames.indexOf(d.trim());
          if (index != -1) daysBool[index] = true;
        }

        Medicine m = Medicine(
          int.parse(row['id'].toString()),
          row['medicine_name'],
          daysBool,
          int.parse(row['dosage'].toString()),
          row['time'],
        );

        _medicines.add(m);
      }

      update(true);
    }
  } catch (e) {
    update(false);
  }
}
void deleteMedicine(Function(String text) update, int id) async {
  try {
    final response = await http.post(
      Uri.http(_baseURL, 'delete.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'id': id,
      }),
    );

    if (response.statusCode == 200) {
      update(response.body); // callback with server response
    }
  } catch (e) {
    update("Connection error: $e");
  }
}

class ShowMedicines extends StatefulWidget{
  final int userId;
  const ShowMedicines({super.key,required this.userId});

  @override
  State<ShowMedicines> createState() => _ShowMedicinesState();
}

class _ShowMedicinesState extends State<ShowMedicines> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final med = _medicines[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.medication_liquid, color: Colors.teal),
            title: Text(med.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(7, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: med.days[i] ? Colors.teal : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        Medicine.dayLetters[i],
                        style: TextStyle(
                          color: med.days[i] ? Colors.white : Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text("Dosage: ${med.dosage} pill(s)"),
                Text("Time: ${med.time}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // UPDATE BUTTON
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicineFormPage(
                          userId: widget.userId,
                          medicineId: med.id,
                        ),
                      ),
                    ).then((_) {
                      // Reload medicines after returning from the form
                      getMedicines((success) {
                        setState(() {}); // rebuild the list
                      }, widget.userId);
                    });
                  },
                ),
                // DELETE BUTTON
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    deleteMedicine((responseMessage) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(responseMessage)));

                      setState(() {
                        _medicines.removeAt(index);
                      });
                    }, med.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

