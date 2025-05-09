abstract interface class FavIconRepository {
  Future<String?> getIconUrl(String url);

  String? getIconUrlSync(String url);
  bool hasIconUrlInRuntime(String url);
}
