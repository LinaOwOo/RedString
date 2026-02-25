import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redstring/features/heart_beat/model/heartbeat_model.dart';
import 'package:redstring/features/heart_beat/screen.dart';
import 'package:redstring/providers/heartbeat_provider.dart';

class HeartbeatList extends StatelessWidget {
  const HeartbeatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appGradientColor.withOpacity(0.5), width: 1),
      ),
      child: Consumer<HeartbeatProvider>(
        builder: (context, provider, child) {
          final beats = provider.heartbeats;

          if (beats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Color(0xFFC9C7FF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Нажмите на сердце,\nчтобы отправить биение',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFC9C7FF),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }

          final groupedBeats = _groupByDate(beats);

          return ListView.builder(
            padding: EdgeInsets.only(top: 20),
            itemCount: groupedBeats.length,
            itemBuilder: (context, index) {
              final date = groupedBeats.keys.elementAt(index);
              final dayBeats = groupedBeats[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  ...dayBeats.map(
                    (beat) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: HeartbeatTile(heartbeat: beat),
                    ),
                  ),

                  SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, List<HeartBeat>> _groupByDate(List<HeartBeat> beats) {
    final Map<String, List<HeartBeat>> grouped = {};

    for (var beat in beats) {
      final dateKey = beat.formattedDate;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(beat);
    }

    return grouped;
  }
}

class HeartbeatTile extends StatelessWidget {
  final HeartBeat heartbeat;

  const HeartbeatTile({super.key, required this.heartbeat});

  @override
  Widget build(BuildContext context) {
    final isFromPartner = heartbeat.isFromPartner;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isFromPartner ? Colors.pink : Colors.purple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isFromPartner ? Colors.pink : Colors.purple)
                          .withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Container(width: 2, height: 30, color: Colors.purple.shade200),
            ],
          ),

          SizedBox(width: 16),

          Text(
            heartbeat.formattedTime,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromPartner
                    ? Colors.pink.shade50
                    : Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFromPartner
                      ? Colors.pink.shade200
                      : Colors.purple.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isFromPartner ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFromPartner ? Colors.pink : Colors.purple,
                      ),
                      SizedBox(width: 8),
                      Text(
                        heartbeat.senderName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${heartbeat.distance}м',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
