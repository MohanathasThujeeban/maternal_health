import 'package:flutter/material.dart';

class HealthChatboxScreen extends StatefulWidget {
  final String? initialTopic;

  const HealthChatboxScreen({super.key, this.initialTopic});

  @override
  State<HealthChatboxScreen> createState() => _HealthChatboxScreenState();
}

class _HealthChatboxScreenState extends State<HealthChatboxScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [
    ChatMessage(
      text:
          "Hello! I'm your maternal health assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTopic != null) {
      _handleInitialTopic();
    }
  }

  void _handleInitialTopic() {
    String initialMessage = '';
    String botResponse = '';

    switch (widget.initialTopic) {
      case 'weight':
        initialMessage = 'Is my baby\'s weight normal?';
        botResponse =
            'Based on your baby\'s current weight of 8.2kg at 8 months, your baby is within the healthy weight range! The average weight for an 8-month-old is between 7-10kg. Your baby has been gaining weight steadily, which is a great sign of healthy development.';
        break;
      case 'feeding':
        initialMessage = 'When should I introduce solid foods?';
        botResponse =
            'At 8 months, your baby should already be enjoying solid foods! You can continue introducing new textures and flavors. Try finger foods, soft fruits, cooked vegetables, and small pieces of meat or fish. Always supervise feeding and watch for any allergic reactions.';
        break;
      case 'sleep':
        initialMessage = 'How much sleep does my baby need?';
        botResponse =
            'An 8-month-old baby typically needs 12-15 hours of sleep in a 24-hour period, including 2-3 naps during the day. Most babies this age can sleep through the night (6-8 hours) without feeding. Establishing a bedtime routine helps promote better sleep.';
        break;
      case 'vaccines':
        initialMessage = 'What vaccines are due next?';
        botResponse =
            'According to your vaccination schedule, your baby\'s MMR vaccine is due in 3 days (August 3rd). This vaccine protects against measles, mumps, and rubella. Make sure to keep the appointment with Dr. Prasad Wickramasinghe. After MMR, the next vaccine will be Varicella in September.';
        break;
      case 'teething':
        initialMessage = 'Is it normal for my baby to be teething now?';
        botResponse =
            'Yes, teething usually begins between 6 to 10 months. Your baby may show signs like drooling, irritability, and a desire to chew on things. You can ease discomfort by giving a chilled teething ring or gently massaging the gums with a clean finger.';
        break;
      case 'diaperRash':
        initialMessage = 'How can I treat diaper rash?';
        botResponse =
            'Diaper rash is common and usually caused by prolonged exposure to a wet or dirty diaper. Keep the area clean and dry, change diapers frequently, and apply a diaper rash cream containing zinc oxide. If the rash doesn’t improve in a few days, consult your pediatrician.';
        break;
    }

    if (initialMessage.isNotEmpty) {
      setState(() {
        messages.add(
          ChatMessage(
            text: initialMessage,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
        messages.add(
          ChatMessage(
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String userMessage = _messageController.text.trim();

    setState(() {
      messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response
    Future.delayed(const Duration(milliseconds: 1000), () {
      String botResponse = _generateBotResponse(userMessage);
      setState(() {
        messages.add(
          ChatMessage(
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  String _generateBotResponse(String userMessage) {
    String message = userMessage.toLowerCase();

    if (message.contains('weight') ||
        message.contains('kg') ||
        message.contains('heavy')) {
      return 'Your baby\'s current weight of 8.2kg is excellent for 8 months! This puts your baby in the 75th percentile, which indicates healthy growth. Keep monitoring weight weekly and maintain regular feeding schedule.';
    } else if (message.contains('feed') ||
        message.contains('food') ||
        message.contains('eat')) {
      return 'At 8 months, continue offering variety in foods. Focus on iron-rich foods like meat, beans, and fortified cereals. Avoid honey, nuts, and choking hazards. Breast milk or formula should still be the primary source of nutrition.';
    } else if (message.contains('sleep') ||
        message.contains('nap') ||
        message.contains('night')) {
      return 'Sleep patterns can vary, but most 8-month-olds need 12-15 hours total sleep. If your baby is having sleep issues, try consistent bedtime routines, comfortable room temperature (68-70°F), and avoid screen time before bed.';
    } else if (message.contains('vaccine') ||
        message.contains('shot') ||
        message.contains('immuniz')) {
      return 'Your baby is up to date with most vaccines! The MMR vaccine due on August 3rd is very important. Side effects may include mild fever or rash. Contact your doctor if you have concerns about reactions.';
    } else if (message.contains('fever') ||
        message.contains('sick') ||
        message.contains('temperature')) {
      return 'For babies 8 months old, a fever over 100.4°F (38°C) warrants attention. Give plenty of fluids, dress lightly, and contact your pediatrician if fever persists or baby seems unusually fussy or lethargic.';
    } else if (message.contains('development') ||
        message.contains('milestone') ||
        message.contains('crawl')) {
      return 'At 8 months, babies typically can sit without support, crawl or scoot, pull to standing, and say simple sounds like "mama" or "dada". Each baby develops at their own pace, but discuss any concerns with your pediatrician.';
    } else if (message.contains('teeth') ||
        message.contains('teething') ||
        message.contains('bite')) {
      return 'Teething is common at 8 months! Signs include drooling, wanting to chew everything, and possible fussiness. Offer cold teething toys, gentle gum massage, and consult your doctor if symptoms seem severe.';
    } else {
      return 'I understand your concern. For specific medical questions, I recommend consulting with your pediatrician. I can help with general information about feeding, sleep, development, and routine care. What specific topic would you like to know more about?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Assistant',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F5F2), Color(0xFFFFFFFF)],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: messages[index]);
                },
              ),
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      hintStyle: const TextStyle(
                        fontFamily: 'SpotifyCircular',
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4FC3A1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Health Assistant',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Color(0xFF4FC3A1),
          ),
        ),
        content: const Text(
          'This health assistant provides general information about baby care, feeding, sleep, and development. For medical emergencies or specific health concerns, always consult your pediatrician or healthcare provider.',
          style: TextStyle(fontFamily: 'SpotifyCircular', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                color: Color(0xFF4FC3A1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF4FC3A1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF4FC3A1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 14,
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 11,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D5A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
