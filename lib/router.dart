import 'package:flutter/material.dart';
import 'package:uniport/version_1/models/models.dart';
import 'package:uniport/version_1/screens/screens.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case WelcomePageScreen.routeName:
      return MaterialPageRoute(builder: (context) => const WelcomePageScreen());
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case LoadingScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoadingScreen());
    case ChatScreen.routeName:
      return MaterialPageRoute(builder: (context) => const ChatScreen());
    case MessageScreen.routeName:
      final args = settings.arguments as UserModel;
      return MaterialPageRoute(
        builder: (context) => MessageScreen(
          messageSender: args,
        ),
      );
    case ReportViewScreen.routeName:
      return MaterialPageRoute(builder: (context) => const ReportViewScreen());
    case StudentReportScreen.routeName:
      return MaterialPageRoute(builder: (context) => StudentReportScreen());
    case StudentApproval.routeName:
      return MaterialPageRoute(builder: (context) => const StudentApproval());
    case TeacherApproval.routeName:
      return MaterialPageRoute(builder: (context) => const TeacherApproval());
    case AssignedGroupScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const AssignedGroupScreen());
    case AssignAdvisor.routeName:
      return MaterialPageRoute(builder: (context) => const AssignAdvisor());
    case PersonalInfoScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const PersonalInfoScreen());
    case AcademicInfoScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const AcademicInfoScreen());
    case SetPasswordScreen.routeName:
      return MaterialPageRoute(builder: (context) => const SetPasswordScreen());
    case ForgetPasswordScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const ForgetPasswordScreen());
    case OtpVerifyScreen.routeName:
      final args = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OtpVerifyScreen(
          email: args,
        ),
      );
    case SetNewPasswordScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const SetNewPasswordScreen());

    default:
      return MaterialPageRoute(
        builder: (context) => ErrorScreen(
          error: 'No route defined for ${settings.name}',
        ),
      );
  }
}
