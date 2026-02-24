class HeartBeat {
  final String id;
  final DateTime timestamp;
  final String senderId;
  final String senderName;
  final String receiverId;
  final int distance;
  final bool isFromPartner;

  HeartBeat({
    required this.id,
    required this.timestamp,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    this.distance = 50,
    this.isFromPartner = false,
  });

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final beatDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (beatDate == today) {
      return 'Сегодня';
    } else if (beatDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'distance': distance,
      'isFromPartner': isFromPartner,
    };
  }

  factory HeartBeat.fromJson(Map<String, dynamic> json) {
    return HeartBeat(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Пользователь',
      receiverId: json['receiverId'] ?? '',
      distance: json['distance'] ?? 50,
      isFromPartner: json['isFromPartner'] ?? false,
    );
  }
}
