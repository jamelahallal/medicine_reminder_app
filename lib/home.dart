import 'package:flutter/material.dart';
import 'dart:async';

class Medicine {
  String name;
  List<bool> days;
  String dosage;
  String time;
  final List<String> dayLetters = ["S", "M", "T", "W", "T", "F", "S"];

  Medicine({
    required this.name,
    required this.days,
    required this.dosage,
    required this.time,
  });
}

class MedicineHomePage extends StatefulWidget {
  @override
  _MedicineHomePageState createState() => _MedicineHomePageState();
}

class _MedicineHomePageState extends State<MedicineHomePage> {
  List<Medicine> medicines = [];
  String currentTime = "";
  String lastAlertTime = "";

  // Form fields
  String medicineName = '';
  String dosage = '';
  String time = '';
  List<bool> selectedDays = List.filled(7, false);
  final List<String> dayLetters = ["S", "M", "T", "W", "T", "F", "S"];

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateClock();
    Timer.periodic(Duration(seconds: 1), (timer) {
      updateClock();
      checkMedicineAlert(currentTime);
    });
  }

  void updateClock() {
    final now = DateTime.now();
    setState(() {
      currentTime =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }
  void removeMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
    });
  }
  void checkMedicineAlert(String timeNow) {
    for (var med in medicines) {
      if (med.time == timeNow) {
        if (lastAlertTime == timeNow) return;
        lastAlertTime = timeNow;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Take your medicine NOW!! (${med.name})"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void addMedicine() {
    if (medicineName.isEmpty || dosage.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final newMed = Medicine(
      name: medicineName.trim(),
      days: List.from(selectedDays),
      dosage: dosage.trim(),
      time: time.trim(),
    );

    setState(() {
      medicines.add(newMed);
      medicineName = '';
      dosage = '';
      time = '';
      selectedDays = List.filled(7, false);

      // Clear controllers
      nameController.clear();
      dosageController.clear();
      timeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time: $currentTime"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // --- Form Card ---
          Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Medicine Name"),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: "Paracetamol"),
                    onChanged: (value) => medicineName = value,
                  ),
                  SizedBox(height: 16),
                  Text("Medicine Days"),
                  SizedBox(height: 8),
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
                            dayLetters[index],
                            style: TextStyle(
                              color: selectedDays[index] ? Colors.white : Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  Text("Dosage (number of pills)"),
                  TextField(
                    controller: dosageController,
                    decoration: InputDecoration(hintText: "2"),
                    onChanged: (value) => dosage = value,
                  ),
                  SizedBox(height: 16),
                  Text("Time (hour:minute)"),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(hintText: "22:00"),
                    onChanged: (value) => time = value,
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addMedicine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: Text("Add Medicine"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // --- List of Medicines ---
          if (medicines.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.medication_liquid, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No Medicine Added", style: TextStyle(fontSize: 18)),
                  Text("Add Now", style: TextStyle(color: Colors.teal)),
                ],
              ),
            )
          else
            ...medicines.asMap().entries.map((entry) {
              int index = entry.key;
              Medicine med = entry.value;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.medication_liquid, color: Colors.teal),

                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(med.name),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            medicines.removeAt(index);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Remove",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(7, (i) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: med.days[i] ? Colors.teal : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              med.dayLetters[i],
                              style: TextStyle(
                                color: med.days[i] ? Colors.white : Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 4),
                      Text("Dosage: ${med.dosage} pill(s)"),
                      Text("Time: ${med.time}"),
                    ],
                  ),
                ),
              );
            }).toList(),
         ],
       ),
     );
   }
}