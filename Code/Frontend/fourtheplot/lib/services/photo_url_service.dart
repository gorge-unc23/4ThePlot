class PhotoUrlService {
  static String? currentServerIp;

  static String normalizePhotoUrl(String? url) {
    final rawUrl = url ?? '';
    final serverIp = currentServerIp;
    if (serverIp == null || serverIp.isEmpty || rawUrl.isEmpty) {
      return rawUrl;
    }

    final match = RegExp(r'^(https?://)([^/]+)(/photos/.*)$').firstMatch(rawUrl);
    if (match == null) {
      return rawUrl;
    }

    return '${match.group(1)}$serverIp${match.group(3)}';
  }
}
