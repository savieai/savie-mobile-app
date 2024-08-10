class AppEvent {
  const AppEvent(
    this.name, {
    this.params,
  });

  final String name;
  final Map<String, Object>? params;
}
