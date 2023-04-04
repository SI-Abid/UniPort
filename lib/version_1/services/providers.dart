import 'package:flutter_dotenv/flutter_dotenv.dart';
final remoteServerConfiguration = {
  "server": "https://web.uniport.up.railway.app",
  "serverKey": dotenv.env['API_KEY']!,
};
