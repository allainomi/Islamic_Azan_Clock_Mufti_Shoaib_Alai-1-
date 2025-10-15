import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(const DigitalClockApp());
}

class DigitalClockApp extends StatefulWidget {
  const DigitalClockApp({Key? key}) : super(key: key);

  @override
  State<DigitalClockApp> createState() => _DigitalClockAppState();
}

class _DigitalClockAppState extends State<DigitalClockApp> {
  ThemeMode themeMode = ThemeMode.system;
  String selectedCity = 'Makkah';
  Map<String, Duration> cityOffsets = {
    'Makkah': const Duration(hours: 3),
    'Karachi': const Duration(hours: 5),
    'London': const Duration(hours: 1),
    'New York': const Duration(hours: -4),
    'Tokyo': const Duration(hours: 9),
  };
  Map<String, String> prayerTimes = {
    'Fajr': '05:00',
    'Dhuhr': '12:30',
    'Asr': '15:45',
    'Maghrib': '18:20',
    'Isha': '19:40',
  };
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playAzan() async {
    try {
      await _audioPlayer.play(AssetSource('azan.mp3'));
    } catch (e) {
      // If asset missing or playback fails, ignore (app still runs)
    }
  }

  void _editPrayerTime(String prayer) async {
    final TextEditingController controller = TextEditingController(text: prayerTimes[prayer]);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$prayer وقت تبدیل کریں'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'HH:mm'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                prayerTimes[prayer] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('محفوظ کریں'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Islamic Azan & Clock by Mufti Shoaib Alai',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Islamic Azan & Clock'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'theme_light') {
                  setState(() => themeMode = ThemeMode.light);
                } else if (value == 'theme_dark') {
                  setState(() => themeMode = ThemeMode.dark);
                } else if (value == 'theme_system') {
                  setState(() => themeMode = ThemeMode.system);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'theme_light', child: Text('Light Theme')),
                PopupMenuItem(value: 'theme_dark', child: Text('Dark Theme')),
                PopupMenuItem(value: 'theme_system', child: Text('System Theme')),
              ],
            ),
          ],
        ),
        body: ClockScreen(
          selectedCity: selectedCity,
          cityOffsets: cityOffsets,
          onCityChange: (city) => setState(() => selectedCity = city),
          prayerTimes: prayerTimes,
          onEditPrayer: _editPrayerTime,
          onPlayAzan: _playAzan,
        ),
      ),
    );
  }
}

class ClockScreen extends StatefulWidget {
  final String selectedCity;
  final Map<String, Duration> cityOffsets;
  final void Function(String) onCityChange;
  final Map<String, String> prayerTimes;
  final void Function(String) onEditPrayer;
  final VoidCallback onPlayAzan;

  const ClockScreen({
    Key? key,
    required this.selectedCity,
    required this.cityOffsets,
    required this.onCityChange,
    required this.prayerTimes,
    required this.onEditPrayer,
    required this.onPlayAzan,
  }) : super(key: key);

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now().toUtc().add(widget.cityOffsets[widget.selectedCity]!);
    _updateClock();
  }

  void _updateClock() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        currentTime = DateTime.now().toUtc().add(widget.cityOffsets[widget.selectedCity]!);
      });
      _updateClock();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(currentTime);
    HijriCalendar hijri = HijriCalendar.fromDate(currentTime);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButton<String>(
            value: widget.selectedCity,
            onChanged: (value) => widget.onCityChange(value!),
            items: widget.cityOffsets.keys
                .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
          ),
          const SizedBox(height: 20),
          Text(formattedTime, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(formattedDate, style: const TextStyle(fontSize: 20)),
          Text('ھجری: ${hijri.toFormat("dd MMMM yyyy")}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onPlayAzan,
            child: const Text('آذان سنیں'),
          ),
          const Divider(height: 30),
          const Text('نماز کے اوقات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ...widget.prayerTimes.entries.map((e) => ListTile(
                title: Text('${e.key}: ${e.value}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => widget.onEditPrayer(e.key),
                ),
              )),
          const Spacer(),
          Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.blueAccent,
            child: const Text(
              'حافظ مفتی محمد شعیب خان آلائی',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}