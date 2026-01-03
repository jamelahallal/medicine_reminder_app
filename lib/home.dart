import 'package:flutter/material.dart';
import 'medicineform.dart';
import 'login.dart';
import 'dart:async';
import 'medicine.dart';

class MedicineHomePage extends StatefulWidget {
  final int userId;
  const MedicineHomePage({super.key, required this.userId});

  @override
  _MedicineHomePageState createState() => _MedicineHomePageState();
}

class _MedicineHomePageState extends State<MedicineHomePage> {
  String currentTime = "";
  String lastAlertTime = "";

  bool _load = false; // used to show list or progress bar

  @override
  void initState() {
    super.initState();
    getMedicines(update, widget.userId);
    startClock();
  }

  void startClock() {
    updateClock();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      updateClock();
    });
  }

  void updateClock() {
    final now = DateTime.now();
    setState(() {
      currentTime =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }
  void update(bool success) {
    setState(() {
      _load = true; // show product list
      if (!success) { // API request failed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('failed to load data')));
      }
    });
  }

  void goToAddMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicineFormPage(userId: widget.userId)),
    ).then((_) async {
      setState(() {
        _load = false; // show loading
      });

      getMedicines((success) {
        setState(() {
          _load = true; // show updated list
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to load medicines'))
            );
          }
        });
      }, widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("My Medicines $currentTime",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => getMedicines(update,widget.userId),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: _load
          ?  ShowMedicines(userId: widget.userId)
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: goToAddMedicine,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}