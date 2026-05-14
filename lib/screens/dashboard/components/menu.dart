enum BottomItem {
  home,
  search,
  shorts,
  music,
  comingsoon,
  livetv,
  profile,
}

class BottomBarItem {
  final String Function() title;
  final String icon;
  final String selectedIcon;
  final String type;

  BottomBarItem({
    required this.title,
    required this.icon,
    required this.type,
    required this.selectedIcon,
  });
}