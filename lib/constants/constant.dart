import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
Uuid uuid = const Uuid();
DatabaseReference realTimeDatabaseRef = FirebaseDatabase.instance.ref();
final audioPlayer = AudioPlayer(); 
