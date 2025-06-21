import 'package:flutter/material.dart';
import 'register3_screen.dart';
import 'registration_data.dart';

class Register2Screen extends StatefulWidget {
  final RegistrationData registrationData;
  const Register2Screen({super.key, required this.registrationData});

  @override
  State<Register2Screen> createState() => _Register2ScreenState();
}

class _Register2ScreenState extends State<Register2Screen> {
  late final TextEditingController lmpController;
  late final TextEditingController eddController;
  late final TextEditingController prevPregController;
  late final TextEditingController yearController;
  late final TextEditingController durationController;
  late final TextEditingController modeOfDeliveryController;
  late final TextEditingController birthWeightController;
  late final TextEditingController sexController;
  late final TextEditingController statusController;

  @override
  void initState() {
    super.initState();
    lmpController = TextEditingController(text: widget.registrationData.lmp);
    eddController = TextEditingController(text: widget.registrationData.edd);
    prevPregController = TextEditingController(text: widget.registrationData.previousPregnancies);
    yearController = TextEditingController(text: widget.registrationData.year);
    durationController = TextEditingController(text: widget.registrationData.duration);
    modeOfDeliveryController = TextEditingController(text: widget.registrationData.modeOfDelivery);
    birthWeightController = TextEditingController(text: widget.registrationData.birthWeight);
    sexController = TextEditingController(text: widget.registrationData.sex);
    statusController = TextEditingController(text: widget.registrationData.status);
  }

  @override
  void dispose() {
    lmpController.dispose();
    eddController.dispose();
    prevPregController.dispose();
    yearController.dispose();
    durationController.dispose();
    modeOfDeliveryController.dispose();
    birthWeightController.dispose();
    sexController.dispose();
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: Colors.black54,
              ),
              const SizedBox(height: 8),
              const Text(
                'Date of Last Menstrual Period [LMP]',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(
                hint: '',
                controller: lmpController,
              ),
              const SizedBox(height: 12),
              const Text(
                'Expected Date of Delivery [EDD]',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(
                hint: '',
                controller: eddController,
              ),
              const SizedBox(height: 12),
              const Text(
                'Previous Pregnancies [G1 to G6]',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(
                hint: '',
                controller: prevPregController,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoundedTextField(
                      hint: 'Year',
                      controller: yearController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoundedTextField(
                      hint: 'Duration[wks]',
                      controller: durationController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoundedTextField(
                      hint: 'Mode of delivery',
                      controller: modeOfDeliveryController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoundedTextField(
                      hint: 'Birth weight',
                      controller: birthWeightController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoundedTextField(
                      hint: 'Sex',
                      controller: sexController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoundedTextField(
                      hint: 'Status[Alive/Death]',
                      controller: statusController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      // Save the values to registrationData
                      widget.registrationData.lmp = lmpController.text;
                      widget.registrationData.edd = eddController.text;
                      widget.registrationData.previousPregnancies = prevPregController.text;
                      widget.registrationData.year = yearController.text;
                      widget.registrationData.duration = durationController.text;
                      widget.registrationData.modeOfDelivery = modeOfDeliveryController.text;
                      widget.registrationData.birthWeight = birthWeightController.text;
                      widget.registrationData.sex = sexController.text;
                      widget.registrationData.status = statusController.text;

                      // Navigate to Register3Screen, passing the updated object
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Register3Screen(registrationData: widget.registrationData),
                        ),
                      );
                    },
                    child: const Text('Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  const _RoundedTextField({required this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        style: const TextStyle(
          fontFamily: 'SpotifyCircular',
          fontSize: 16,
        ),
      ),
    );
  }
}