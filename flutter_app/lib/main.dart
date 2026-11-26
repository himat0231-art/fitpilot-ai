import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FitPilotApp());
}

class FitPilotApp extends StatefulWidget {
  const FitPilotApp({super.key});

  @override
  State<FitPilotApp> createState() => _FitPilotAppState();
}

class _FitPilotAppState extends State<FitPilotApp> {
  int tab = 0;

  final name = TextEditingController();
  final age = TextEditingController();
  final budget = TextEditingController(text: '150');

  String diet = 'Vegetarian';
  String goal = 'General fitness';
  bool saved = false;
  File? foodImage;

  final message = TextEditingController();
  final List<Map<String, String>> chats = [];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      name.text = p.getString('name') ?? '';
      age.text = p.getString('age') ?? '';
      budget.text = p.getString('budget') ?? '150';
      diet = p.getString('diet') ?? 'Vegetarian';
      goal = p.getString('goal') ?? 'General fitness';
      saved = p.getBool('saved') ?? false;
    });
  }

  Future<void> saveProfile() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('name', name.text.trim());
    await p.setString('age', age.text.trim());
    await p.setString('budget', budget.text.trim());
    await p.setString('diet', diet);
    await p.setString('goal', goal);
    await p.setBool('saved', true);

    if (!mounted) return;
    setState(() => saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully')),
    );
  }

  Future<void> pickFood() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (image != null && mounted) {
      setState(() => foodImage = File(image.path));
    }
  }

  void sendMessage() {
    final q = message.text.trim();
    if (q.isEmpty) return;

    String answer;
    final lower = q.toLowerCase();

    if (lower.contains('food') || lower.contains('diet')) {
      answer = 'Choose balanced meals with vegetables, fruits, grains and protein sources. Your needs depend on your age, activity and health.';
    } else if (lower.contains('workout') || lower.contains('exercise')) {
      answer = 'Start with comfortable movement, warm up first, use correct form and allow time for recovery. Stop if you feel pain or unwell.';
    } else if (lower.contains('sleep')) {
      answer = 'A regular sleep schedule supports recovery, learning and everyday energy.';
    } else {
      answer = 'I am the FitPilot demo coach. Ask me about balanced nutrition, safe exercise, recovery or healthy routines. Live AI connection is not enabled yet.';
    }

    setState(() {
      chats.add({'user': q, 'bot': answer});
      message.clear();
    });
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    budget.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitPilot AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF28B887),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101714),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FITPILOT AI'),
          backgroundColor: const Color(0xFF18251F),
        ),
        body: IndexedStack(
          index: tab,
          children: [
            homePage(),
            profilePage(),
            foodPage(),
            coachPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
            NavigationDestination(icon: Icon(Icons.restaurant_outlined), label: 'Food AI'),
            NavigationDestination(icon: Icon(Icons.smart_toy_outlined), label: 'Coach'),
          ],
        ),
      ),
    );
  }

  Widget homePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 12),
        const Text(
          'Your fitness journey starts here.',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(saved ? 'Welcome, ${name.text}!' : 'Set up your profile to get started.'),
        const SizedBox(height: 22),
        metric('Your Profile', saved ? 'Saved' : 'Not set up', Icons.person),
        metric('Nutrition', 'Balanced food guidance', Icons.restaurant),
        metric('Training', 'Safe movement guidance', Icons.fitness_center),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () => setState(() => tab = 1),
          child: const Text('Set up / Edit Profile'),
        ),
        FilledButton.tonal(
          onPressed: () => setState(() => tab = 2),
          child: const Text('Open Food AI'),
        ),
        FilledButton.tonal(
          onPressed: () => setState(() => tab = 3),
          child: const Text('Talk to Coach'),
        ),
      ],
    );
  }

  Widget metric(String title, String subtitle, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF52D6A4), size: 30),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget profilePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Your Profile', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Share only information you are comfortable providing.'),
        const SizedBox(height: 18),
        field('Name', name),
        field('Age', age, number: true),
        field('Daily food budget (optional)', budget, number: true),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: diet,
          decoration: const InputDecoration(labelText: 'Food preference', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'Vegetarian', child: Text('Vegetarian')),
            DropdownMenuItem(value: 'Non-vegetarian', child: Text('Non-vegetarian')),
            DropdownMenuItem(value: 'Vegan', child: Text('Vegan')),
            DropdownMenuItem(value: 'No preference', child: Text('No preference')),
          ],
          onChanged: (v) => setState(() => diet = v ?? diet),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: goal,
          decoration: const InputDecoration(labelText: 'Your goal', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'General fitness', child: Text('General fitness')),
            DropdownMenuItem(value: 'Strength and mobility', child: Text('Strength and mobility')),
            DropdownMenuItem(value: 'Improve stamina', child: Text('Improve stamina')),
            DropdownMenuItem(value: 'Build healthy habits', child: Text('Build healthy habits')),
          ],
          onChanged: (v) => setState(() => goal = v ?? goal),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: saveProfile,
          icon: const Icon(Icons.save),
          label: const Text('Save Profile'),
        ),
        if (saved)
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: Text('Your profile is saved on this device.'),
          ),
      ],
    );
  }

  Widget field(String label, TextEditingController controller, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget foodPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Food AI', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Choose a food photo. Photo selection works; automatic food recognition is not connected yet.'),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: pickFood,
          icon: const Icon(Icons.photo_library),
          label: const Text('Choose Food Photo'),
        ),
        const SizedBox(height: 18),
        if (foodImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(foodImage!, height: 260, fit: BoxFit.cover),
          ),
        if (foodImage != null)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Photo selected. Nutrition estimates require a vision AI service and portion information.'),
          ),
      ],
    );
  }

  Widget coachPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('FitPilot Coach', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: chats.isEmpty
              ? const Center(child: Text('Ask about nutrition, movement or recovery.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: chats.length,
                  itemBuilder: (context, i) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(chats[i]['user']!),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Card(
                          color: const Color(0xFF214536),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(chats[i]['bot']!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: message,
                  decoration: const InputDecoration(
                    hintText: 'Ask your coach...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
