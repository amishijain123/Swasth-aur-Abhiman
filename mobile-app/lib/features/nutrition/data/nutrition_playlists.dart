/// Static mapping of nutrition categories to YouTube playlist or video URLs.
class NutritionPlaylists {
  static const Map<String, String> _map = {
    'general': 'https://www.youtube.com/playlist?list=PLgZydgWJiHdEB7jVxEzy8krmSEsl7q9NG',
    'general wellness': 'https://www.youtube.com/playlist?list=PLgZydgWJiHdEB7jVxEzy8krmSEsl7q9NG',
    'diabetes': 'https://www.youtube.com/watch?v=2A3G2zzBydA',
    'diabetes diet': 'https://www.youtube.com/watch?v=2A3G2zzBydA',
    'child nutrition': 'https://www.youtube.com/watch?v=EhfOZMOF9W4',
    'children': 'https://www.youtube.com/watch?v=EhfOZMOF9W4',
    'pregnancy': 'https://www.youtube.com/watch?v=N_PglaMSA2k',
    'pregnancy nutrition': 'https://www.youtube.com/watch?v=N_PglaMSA2k',
    'anemia': 'https://www.youtube.com/playlist?list=PLTyIxn63-KSFeW0w7OwxxQ8c7b2vNBn1T',
    'anemia diet': 'https://www.youtube.com/playlist?list=PLTyIxn63-KSFeW0w7OwxxQ8c7b2vNBn1T',
    'post_covid': 'https://www.youtube.com/watch?v=_dVuHFdUN0c',
    'post-covid recovery': 'https://www.youtube.com/watch?v=_dVuHFdUN0c',
    'post-covid': 'https://www.youtube.com/watch?v=_dVuHFdUN0c',
  };

  static String? getPlaylist(String key) {
    if (key.isEmpty) return null;
    final lk = key.toLowerCase();
    if (_map.containsKey(key)) return _map[key];
    if (_map.containsKey(lk)) return _map[lk];
    final entry = _map.entries.firstWhere(
      (e) => lk.contains(e.key),
      orElse: () => const MapEntry('', ''),
    );
    return entry.value.isEmpty ? null : entry.value;
  }
}
