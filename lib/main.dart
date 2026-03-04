import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Bibliothèque',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion Bibliothèque'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              ' Connexion Réussie!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Firebase est correctement configuré',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Informations de connexion:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(
                      'Projet ID',
                      DefaultFirebaseOptions.currentPlatform.projectId,
                    ),
                    _buildInfoRow(
                      'App ID',
                      DefaultFirebaseOptions.currentPlatform.appId,
                    ),
                    _buildInfoRow(
                      'API Key',
                      _maskApiKey(
                        DefaultFirebaseOptions.currentPlatform.apiKey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Naviguer vers votre application principale
                // Navigator.push(context, MaterialPageRoute(builder: (context) => MainApp()));
              },
              icon: Icon(Icons.arrow_forward),
              label: Text('Continuer vers l\'application'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontFamily: 'Monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _maskApiKey(String apiKey) {
    if (apiKey.length < 8) return apiKey;
    return '${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 4)}';
  }
}

// Application d'erreur si Firebase échoue
class FirebaseErrorApp extends StatelessWidget {
  final String error;

  const FirebaseErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(
          title: Text('Erreur de Configuration'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                '❌ Erreur de Connexion Firebase',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails de l\'erreur:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        error,
                        style: TextStyle(
                          fontFamily: 'Monospace',
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Veuillez vérifier:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              _buildChecklistItem(
                'google-services.json présent dans android/app/',
              ),
              _buildChecklistItem('Dépendances Firebase dans pubspec.yaml'),
              _buildChecklistItem('Configuration FlutterFire CLI'),
              _buildChecklistItem(
                'Clés API correctes dans firebase_options.dart',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: Colors.red),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}