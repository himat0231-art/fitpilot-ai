import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const apiBase = String.fromEnvironment(
  'FITPILOT_API',
  defaultValue: 'http://10.0.2.2:8000',
);

void main() => runApp(const FitPilotApp());

class FitPilotApp extends StatelessWidget {
  const FitPilotApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FitPilot AI',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF28B887), brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF101714),
      useMaterial3: true,
      cardTheme: const CardThemeData(color: Color(0xFF1A2520), elevation: 0),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final name = TextEditingController();
  final age = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  final budget = TextEditingController(text: '150');
  final goal = 'General fitness';
  String diet = 'Vegetarian';
  String result = 'Your personalized plan will appear here.';
  String foodResult = 'Upload a food photo to get an estimate. Confirm portion size for better accuracy.';
  bool loading = false;
  XFile? selectedImage;

  Future<void> requestPlan() async {
    setState(() { loading = true; result = 'Creating your plan…'; });
    try {
      final response = await http.post(
        Uri.parse('$apiBase/plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.text,
          'age': int.tryParse(age.text) ?? 18,
          'height_cm': double.tryParse(height.text) ?? 0,
          'weight_kg': double.tryParse(weight.text) ?? 0,
          'daily_food_budget_inr': double.tryParse(budget.text) ?? 150,
          'diet_preference': diet,
          'goal': goal,
        }),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        result = data['plan'] ?? 'No plan returned.';
      } else {
        result = 'The AI service is not configured yet. Start the backend and add an API key. You can still explore the app demo.';
      }
    } catch (_) {
      result = 'Could not reach the backend. Start the backend and check the API address. Demo mode is available.';
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> pickFood() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image == null) return;
    setState(() { selectedImage = image; foodResult = 'Photo selected. Connect the vision AI service to analyze it.'; });
  }

  Widget dashboard() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('FITPILOT AI', style: TextStyle(letterSpacing: 2, color: Color(0xFF66D9A8), fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    const Text('Your fitness, guided.', style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold)),
    const Text('A practical starting point for food, movement and consistency.', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 20),
    Row(children: [
      Expanded(child: metric('Nutrition', 'Track meals', Icons.restaurant)),
      const SizedBox(width: 10),
      Expanded(child: metric('Training', 'Build routine', Icons.fitness_center)),
    ]),
    const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Your next step', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Add your profile to get a starter plan. Plans are general guidance, not medical care.'),
      const SizedBox(height: 12),
      FilledButton(onPressed: () => setState(() => tab = 1), child: const Text('Set up profile')),
    ]))),
    const SizedBox(height: 12),
    Card(child: ListTile(leading: const Icon(Icons.smart_toy), title: const Text('AI Coach'), subtitle: const Text('Ask about meals, workouts and habits'), onTap: () => setState(() => tab = 3))),
  ]);

  Widget metric(String title, String subtitle, IconData icon) => Card(child: Padding(
    padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF66D9A8)), const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ]),
  ));

  Widget profile() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('Your profile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6),
    const Text('Only enter information you are comfortable sharing. A photo is optional.', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 16),
    field('Name (optional)', name), field('Age', age, numeric: true),
    field('Height (cm)', height, numeric: true), field('Weight (kg)', weight, numeric: true),
    field('Daily food budget (₹)', budget, numeric: true),
    DropdownButtonFormField<String>(value: diet, decoration: const InputDecoration(labelText: 'Food preference', border: OutlineInputBorder()), items: ['Vegetarian','Non-vegetarian','Vegan','Eggetarian'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => diet = v!)),
    const SizedBox(height: 14),
    FilledButton.icon(onPressed: loading ? null : requestPlan, icon: const Icon(Icons.auto_awesome), label: Text(loading ? 'Working…' : 'Generate starter plan')),
    const SizedBox(height: 14),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: SelectableText(result))),
    const SizedBox(height: 10),
    const Text('For users under 18, involve a parent/guardian and qualified health professional before making major diet or training changes. This app does not prescribe weight-loss diets.', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
  ]);

  Widget field(String label, TextEditingController c, {bool numeric = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: c, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
  );

  Widget food() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('Food photo estimator', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Photo-based nutrition is an estimate. Ingredients and serving size can change the result substantially.', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 18),
    OutlinedButton.icon(onPressed: pickFood, icon: const Icon(Icons.add_a_photo), label: const Text('Choose food photo')),
    if (selectedImage != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text('Selected: ${selectedImage!.name}')),
    const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(foodResult))),
    const SizedBox(height: 12),
    const Text('MVP note: image selection is implemented; vision analysis needs a configured vision model and secure server-side API key.', style: TextStyle(color: Colors.white60, fontSize: 12)),
  ]);

  Widget coach() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('AI Coach', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('The coach endpoint will be connected after the AI provider is configured.'),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: const Text('Try asking: “Suggest an affordable vegetarian lunch” or “Explain how to do a safe beginner squat.”'))),
    const Text('The coach should not diagnose conditions, recommend supplements as treatment, or give extreme diet plans.', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
  ]);

  @override
  Widget build(BuildContext context) {
    final pages = [dashboard(), profile(), food(), coach()];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt), label: 'Food AI'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'Coach'),
        ],
      ),
    );
  }
}
