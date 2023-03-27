import 'package:email_auth/email_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

final remoteServerConfiguration = {
  "server": "https://web.uniport.up.railway.app",
  "serverKey": dotenv.env['API_KEY']!,
};

String otpHolder = '';

late User loggedInUser;
late EmailAuth emailAuth;
late SharedPreferences prefs;
late GoogleSignIn google;
