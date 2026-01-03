import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'medicine.dart';

//server URL
const String _baseURL = 'http://medecine.atwebpages.com';

class MedicineFormPage extends StatefulWidget {
  final int userId;
  final int? medicineId;
  const MedicineFormPage({super.key, required this.userId,this.medicineId});

  @override
  State<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends State<MedicineFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  List<bool> selectedDays = List.filled(7, false);

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    timeController.dispose();
    super.dispose();
  }

  bool _loading = false;

  void update(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      _loading = false;
    });
  }

  void addMedicine() {
    final name = nameController.text.trim();
    final dosageText = dosageController.text.trim();
    final medTimeInput = timeController.text.trim();

// Validate format "HH:mm"
    final parts = medTimeInput.split(':');
    if (parts.length != 2) {
      update("Time must be in HH:mm format");
      return;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      update("Invalid time, must be 00:00 to 23:59");
      return;
    }

// Format back to always "HH:mm" (e.g., "09:05")
    final medTime = "${hour.toString().padLeft(2,'0')}:${minute.toString().padLeft(2,'0')}";

    if (name.isEmpty || dosageText.isEmpty || medTime.isEmpty) {
      update("Please fill all fields");
      return;
    }

    final dosage = int.tryParse(dosageText);
    if (dosage == null) {
      update("Dosage must be a number");
      return;
    }

    if (!selectedDays.contains(true)) {
      update("Please select at least one day");
      return;
    }

    List<String> dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    String daysString = selectedDays
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => dayNames[e.key])
        .join(",");

    setState(() { _loading = true; });

    if (widget.medicineId == null) {
      // Add new medicine
      saveaddmedicine((res) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
        Navigator.pop(context); // just close the form
      }, widget.userId, name, daysString, dosage, medTime);
    } else {
      // Update existing medicine
      saveUpdateMedicine((res) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
        Navigator.pop(context, "refresh");
      }, widget.medicineId!, name, daysString, dosage, medTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Form",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Medicine Name"),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Paracetamol"),
            ),
            const SizedBox(height: 16),
            const Text("Medicine Days"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDays[index] = !selectedDays[index];
                    });
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: selectedDays[index]
                        ? Colors.teal
                        : Colors.teal.shade100,
                    child: Text(
                      Medicine.dayLetters[index],
                      style: TextStyle(
                        color: selectedDays[index] ? Colors.white : Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text("Dosage (number of pills)"),
            TextField(
              controller: dosageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "2"),
            ),
            const SizedBox(height: 16),
            const Text("Time (hour:minute)"),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(hintText: "22:00"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : addMedicine, // call submitMedicine
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  widget.medicineId == null ? "Add Medicine" : "Update Medicine",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void saveaddmedicine(Function(String text) update,int userId, String name,
    String days, int dosage, String time) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseURL/add.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode({
        'user_id': userId,
        'medicine_name': name,
        'days': days,
        'dosage': dosage.toString(),
        'time': time,
      }),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      update("Medicine added successfully!");
    } else {
      update("Failed: ${response.statusCode}");
    }
  } catch (e) {
    update("Connection error: $e");
  }
}
void saveUpdateMedicine(Function(String) update, int medicineId, String name,
    String days, int dosage, String time) async {
  try {
    await http.post(
      Uri.parse('$_baseURL/update.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: convert.jsonEncode({
        'id': medicineId,
        'medicine_name': name,
        'days': days,
        'dosage': dosage.toString(),
        'time': time,
      }),
    );
    update("Medicine updated successfully!");
  } catch (e) {
    update("Connection error: $e");
  }
}
