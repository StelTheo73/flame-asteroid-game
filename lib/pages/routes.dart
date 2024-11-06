enum AppRoute {
  game('/game'),
  home('/'),
  levels('/levels');

  const AppRoute(this.route);

  final String route;
}
