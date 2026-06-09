class AppState {
  // Private Constructor
  AppState._internal();
  static final AppState instance = AppState._internal();

  // Observable Data
  List<Map<String, dynamic>> activeListings = [];
  Map<String, dynamic>? currentUser;

  void clearCache() {
    activeListings.clear();
  }
}
