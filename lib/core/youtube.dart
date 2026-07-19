import 'package:url_launcher/url_launcher.dart';

Uri youtubeSearchUrl(String exerciseName) {
  return Uri.https('www.youtube.com', '/results', {
    'search_query': '$exerciseName como fazer',
  });
}

Future<bool> abrirTutorialYoutube(String exerciseName) {
  return launchUrl(
    youtubeSearchUrl(exerciseName),
    mode: LaunchMode.externalApplication,
  );
}
