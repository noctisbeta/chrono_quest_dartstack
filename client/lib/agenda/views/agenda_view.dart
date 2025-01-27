import 'package:chrono_quest/agenda/components/activity_tile.dart';
import 'package:chrono_quest/agenda/components/agenda_timeline.dart';
import 'package:flutter/material.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text('Agenda'),
        ),
        body: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: const AgendaTimeline(),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  const Text(
                    'Upcoming Activities',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    spacing: 12,
                    children: [
                      ActivityTile(
                        title: 'Activity 1',
                        subtitle: 'Details about activity 1',
                        icon: Icons.access_alarm,
                        onTap: () {},
                      ),
                      ActivityTile(
                        title: 'Activity 2',
                        subtitle: 'Details about activity 2',
                        icon: Icons.access_alarm,
                        onTap: () {},
                      ),
                      ActivityTile(
                        title: 'Activity 3',
                        subtitle: 'Details about activity 3',
                        icon: Icons.access_alarm,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
