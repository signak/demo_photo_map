enum ReleaseRoutes {
  error('error', isTopLevel: true),
  loading('loading', isTopLevel: true),
  signIn('signIn', isTopLevel: true),
  signUp('signUp', isTopLevel: true),
  home('home', path: '/', isTopLevel: true),
  edit('edit', path: 'edit/:id', paramName: 'id'),
  gallery('gallery', path: 'g/:index', paramName: 'index'),
  photoView('view', path: 'v/:imageIndex', paramName: 'imageIndex'),
  admin('admin'),
  authorization('authorization'),
  logView('logs'),
  ;

  const ReleaseRoutes(
    this.name, {
    String? path,
    String? paramName,
    this.isTopLevel = false,
  })  : _path = path,
        _paramName = paramName;
  final String name;
  final String? _path;
  final String? _paramName;
  final bool isTopLevel;
  String get path =>
      _path ?? ((isTopLevel) ? '/${name.toLowerCase()}' : name.toLowerCase());
  String get paramName => _paramName ?? '';
  bool get hasParam => (_paramName != null);
}
