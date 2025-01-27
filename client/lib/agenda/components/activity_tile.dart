import 'package:flutter/material.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    super.key,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<Color?> colors = [
      Colors.pink[100],
      Colors.blue[100],
      Colors.green[100],
      Colors.yellow[100],
      Colors.orange[100],
      Colors.purple[100],
    ];
    final Color? randomColor = (colors..shuffle()).first;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: randomColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
