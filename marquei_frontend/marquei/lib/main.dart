import 'package:flutter/material.dart';
import 'package:marquei/views/auth.dart';
import 'package:marquei/views/estabelecimentos.dart';
import 'package:marquei/views/map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:marquei/views/addplace_view.dart';
import 'package:marquei/views/mapa_estabelecimentos.dart';
import 'package:marquei/views/id_usuario.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
      routes: {
        '/add-place': (context) => const AddPlaces(),
        '/map': (context) => const MapPage(),
        '/all-establishments': (context) => const AllEstablishmentsScreen(),
        '/mapa-estabelecimentos': (context) => const MapaEstabelecimentos(),
        '/sessao': (context) => UserIdCheckScreen()

      },
    );
  }
}