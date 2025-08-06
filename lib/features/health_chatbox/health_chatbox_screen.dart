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
  
  // Add view state management
  bool _showCategories = true;
  String? _selectedCategory;

  List<ChatMessage> messages = [
    ChatMessage(
      text: "Hello! I'm your maternal health assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  // Predefined categories
  final List<HealthCategory> categories = [
    HealthCategory(
      id: 'pregnancy',
      title: 'Pregnancy Care',
      icon: Icons.favorite,
      color: Color(0xFF4FC3A1),
      description: 'Prenatal care, symptoms, and wellness tips',
    ),
    HealthCategory(
      id: 'childcare',
      title: 'Child Care',
      icon: Icons.child_care,
      color: Color(0xFF2E7D5A),
      description: 'Newborn care, development milestones',
    ),
    HealthCategory(
      id: 'nutrition',
      title: 'Nutrition',
      icon: Icons.restaurant,
      color: Color(0xFF4FC3A1),
      description: 'Diet plans, healthy eating guidelines',
    ),
    HealthCategory(
      id: 'vaccination',
      title: 'Vaccination',
      icon: Icons.health_and_safety,
      color: Color(0xFF2E7D5A),
      description: 'Immunization schedules and information',
    ),
  ];

  // Predefined questions
  final Map<String, List<PredefinedQuestion>> categoryQuestions = {
    'pregnancy': [
      PredefinedQuestion(
        question: "What should I eat during pregnancy?",
        answer: "Focus on a balanced diet rich in folate, iron, calcium, and protein. Include leafy greens, lean meats, dairy products, whole grains, and fruits. Avoid raw fish, unpasteurized products, and limit caffeine to 200mg per day.",
      ),
      PredefinedQuestion(
        question: "How much weight should I gain?",
        answer: "Weight gain depends on your pre-pregnancy BMI:\n• Normal weight (18.5-24.9): 25-35 lbs\n• Underweight: 28-40 lbs\n• Overweight: 15-25 lbs\n• Obese: 11-20 lbs\n\nConsult your healthcare provider for personalized advice.",
      ),
      PredefinedQuestion(
        question: "What are normal pregnancy symptoms?",
        answer: "Common symptoms include:\n• Morning sickness (nausea/vomiting)\n• Fatigue and tiredness\n• Breast tenderness\n• Frequent urination\n• Mood changes\n• Food aversions or cravings\n\nContact your doctor if symptoms are severe or concerning.",
      ),
      PredefinedQuestion(
        question: "When should I contact my doctor?",
        answer: "Contact immediately for:\n• Severe abdominal pain\n• Heavy bleeding\n• Severe headaches\n• Vision changes\n• Persistent vomiting\n• Decreased fetal movement after 28 weeks\n• Signs of preterm labor\n• High fever or chills",
      ),
    ],
    'childcare': [
      PredefinedQuestion(
        question: "How often should I feed my newborn?",
        answer: "Newborns typically feed every 2-3 hours, or 8-12 times per day. Breastfed babies may feed more frequently. Watch for hunger cues like:\n• Rooting or searching for breast\n• Sucking motions\n• Fussiness or crying\n• Moving hands to mouth",
      ),
      PredefinedQuestion(
        question: "When do babies start sleeping through the night?",
        answer: "Most babies can sleep through the night (6-8 hours) by 3-6 months, but every baby is different. Tips for better sleep:\n• Establish bedtime routine\n• Safe sleep practices (back sleeping)\n• Consistent sleep environment\n• Day/night differentiation",
      ),
      PredefinedQuestion(
        question: "What are important developmental milestones?",
        answer: "Key milestones by age:\n• 2 months: Social smiles, tracks objects\n• 4 months: Holds head up, laughs\n• 6 months: Sits with support, babbles\n• 9 months: Crawls, says 'mama/dada'\n• 12 months: First steps, first words\n• 18 months: Walks independently, 10+ words",
      ),
      PredefinedQuestion(
        question: "How to handle excessive baby crying?",
        answer: "Check if baby:\n• Is hungry or needs feeding\n• Needs diaper change\n• Is tired or overstimulated\n• Is uncomfortable (too hot/cold)\n\nSoothing techniques:\n• Swaddling\n• Gentle rocking or bouncing\n• White noise or soft music\n• Skin-to-skin contact\n\nIf crying persists for hours, consult pediatrician.",
      ),
    ],
    'nutrition': [
      PredefinedQuestion(
        question: "What foods should I avoid while breastfeeding?",
        answer: "Generally, most foods are safe while breastfeeding:\n• Limit caffeine to 1-2 cups coffee/day\n• Avoid alcohol or pump and dump\n• Limit high-mercury fish\n• Watch for baby's reactions to spicy foods\n\nIf baby shows sensitivity (fussiness, rash), consider temporarily eliminating potential allergens.",
      ),
      PredefinedQuestion(
        question: "When can I introduce solid foods?",
        answer: "Start introducing solids around 6 months when baby:\n• Can sit up with minimal support\n• Has good head and neck control\n• Shows interest in food\n• Can move food to back of mouth\n\nStart with single-ingredient foods like iron-fortified cereal or pureed vegetables.",
      ),
      PredefinedQuestion(
        question: "What are good first foods for babies?",
        answer: "Recommended first foods:\n• Iron-fortified baby cereal\n• Pureed vegetables (sweet potato, carrots, peas)\n• Pureed fruits (banana, apple, pear)\n• Well-cooked, mashed legumes\n• Avocado\n\nIntroduce one food at a time for 3-5 days to watch for allergic reactions.",
      ),
    ],
    'vaccination': [
      PredefinedQuestion(
        question: "What vaccines does my baby need?",
        answer: "Key vaccines by schedule:\n• Birth: Hepatitis B\n• 2 months: DTaP, Hib, PCV13, IPV, RV\n• 4 months: DTaP, Hib, PCV13, IPV, RV\n• 6 months: DTaP, Hib, PCV13, IPV, RV\n• 12-15 months: MMR, Varicella, PCV13\n• 15-18 months: DTaP, Hib\n\nFollow your pediatrician's recommended schedule.",
      ),
      PredefinedQuestion(
        question: "Are vaccines safe for my baby?",
        answer: "Yes, vaccines are thoroughly tested for safety and effectiveness:\n• Undergo rigorous clinical trials\n• Continuously monitored for safety\n• Benefits far outweigh risks\n• Serious side effects are extremely rare\n\nCommon mild reactions: slight fever, soreness at injection site, mild fussiness.",
      ),
      PredefinedQuestion(
        question: "What if my child misses a vaccination?",
        answer: "If your child misses vaccines:\n• Contact your healthcare provider\n• No need to restart the entire series\n• Provider will create catch-up schedule\n• Based on child's current age\n• Important to catch up as soon as possible\n\nDelayed vaccines still provide protection once given.",
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialTopic != null) {
      _handleInitialTopic();
      setState(() {
        _showCategories = false;
      });
    }
  }

  void _handleInitialTopic() {
    // Your existing initial topic handling code remains the same
    String initialMessage = '';
    String botResponse = '';

    switch (widget.initialTopic) {
      case 'weight':
        initialMessage = 'Is my baby\'s weight normal?';
        botResponse = 'Based on your baby\'s current weight of 8.2kg at 8 months, your baby is within the healthy weight range! The average weight for an 8-month-old is between 7-10kg. Your baby has been gaining weight steadily, which is a great sign of healthy development.';
        break;
      case 'feeding':
        initialMessage = 'When should I introduce solid foods?';
        botResponse = 'At 8 months, your baby should already be enjoying solid foods! You can continue introducing new textures and flavors. Try finger foods, soft fruits, cooked vegetables, and small pieces of meat or fish. Always supervise feeding and watch for any allergic reactions.';
        break;
      case 'sleep':
        initialMessage = 'How much sleep does my baby need?';
        botResponse = 'An 8-month-old baby typically needs 12-15 hours of sleep in a 24-hour period, including 2-3 naps during the day. Most babies this age can sleep through the night (6-8 hours) without feeding. Establishing a bedtime routine helps promote better sleep.';
        break;
      case 'vaccines':
        initialMessage = 'What vaccines are due next?';
        botResponse = 'According to your vaccination schedule, your baby\'s MMR vaccine is due in 3 days (August 3rd). This vaccine protects against measles, mumps, and rubella. Make sure to keep the appointment with Dr. Prasad Wickramasinghe. After MMR, the next vaccine will be Varicella in September.';
        break;
      case 'teething':
        initialMessage = 'Is it normal for my baby to be teething now?';
        botResponse = 'Yes, teething usually begins between 6 to 10 months. Your baby may show signs like drooling, irritability, and a desire to chew on things. You can ease discomfort by giving a chilled teething ring or gently massaging the gums with a clean finger.';
        break;
      case 'diaperRash':
        initialMessage = 'How can I treat diaper rash?';
        botResponse = 'Diaper rash is common and usually caused by prolonged exposure to a wet or dirty diaper. Keep the area clean and dry, change diapers frequently, and apply a diaper rash cream containing zinc oxide. If the rash doesn\'t improve in a few days, consult your pediatrician.';
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

  void _selectCategory(HealthCategory category) {
    setState(() {
      _selectedCategory = category.id;
      _showCategories = false;
    });
  }

  void _selectPredefinedQuestion(PredefinedQuestion question) {
    setState(() {
      messages.add(
        ChatMessage(
          text: question.question,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();

    // Simulate bot response delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        messages.add(
          ChatMessage(
            text: question.answer,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _backToCategories() {
    setState(() {
      _showCategories = true;
      _selectedCategory = null;
    });
  }

  void _startChatting() {
    setState(() {
      _showCategories = false;
      _selectedCategory = null;
    });
  }

  // Your existing methods remain the same
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
    // Your existing response generation logic remains the same
    String message = userMessage.toLowerCase();

    if (message.contains('weight') || message.contains('kg') || message.contains('heavy')) {
      return 'Your baby\'s current weight of 8.2kg is excellent for 8 months! This puts your baby in the 75th percentile, which indicates healthy growth. Keep monitoring weight weekly and maintain regular feeding schedule.';
    } else if (message.contains('feed') || message.contains('food') || message.contains('eat')) {
      return 'At 8 months, continue offering variety in foods. Focus on iron-rich foods like meat, beans, and fortified cereals. Avoid honey, nuts, and choking hazards. Breast milk or formula should still be the primary source of nutrition.';
    } else if (message.contains('sleep') || message.contains('nap') || message.contains('night')) {
      return 'Sleep patterns can vary, but most 8-month-olds need 12-15 hours total sleep. If your baby is having sleep issues, try consistent bedtime routines, comfortable room temperature (68-70°F), and avoid screen time before bed.';
    } else if (message.contains('vaccine') || message.contains('shot') || message.contains('immuniz')) {
      return 'Your baby is up to date with most vaccines! The MMR vaccine due on August 3rd is very important. Side effects may include mild fever or rash. Contact your doctor if you have concerns about reactions.';
    } else if (message.contains('fever') || message.contains('sick') || message.contains('temperature')) {
      return 'For babies 8 months old, a fever over 100.4°F (38°C) warrants attention. Give plenty of fluids, dress lightly, and contact your pediatrician if fever persists or baby seems unusually fussy or lethargic.';
    } else if (message.contains('development') || message.contains('milestone') || message.contains('crawl')) {
      return 'At 8 months, babies typically can sit without support, crawl or scoot, pull to standing, and say simple sounds like "mama" or "dada". Each baby develops at their own pace, but discuss any concerns with your pediatrician.';
    } else if (message.contains('teeth') || message.contains('teething') || message.contains('bite')) {
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
        title: Text(
          _showCategories ? 'Health Assistant' : 
          _selectedCategory != null ? 
            categories.firstWhere((c) => c.id == _selectedCategory).title :
            'Health Assistant',
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_selectedCategory != null) {
              _backToCategories();
            } else if (!_showCategories && widget.initialTopic == null) {
              _backToCategories();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_showCategories)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: _startChatting,
            ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _showCategories ? _buildCategoriesView() : _buildChatView(),
    );
  }

  Widget _buildCategoriesView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5F2), Color(0xFFFFFFFF)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FC3A1), Color(0xFF2E7D5A)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose a Health Topic',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D5A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a category to get expert answers to your questions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            
            // Categories Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(HealthCategory category) {
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: const TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    final questions = _selectedCategory != null ? 
        categoryQuestions[_selectedCategory!] ?? [] : <PredefinedQuestion>[];
    
    return Column(
      children: [
        // Show predefined questions if category is selected
        if (_selectedCategory != null && questions.isNotEmpty) ...[
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F5F2), Color(0xFFFFFFFF)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Quick Questions:',
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D5A),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _selectPredefinedQuestion(question),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                question.question,
                                style: const TextStyle(
                                  fontFamily: 'SpotifyCircular',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2E7D5A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],

        // Chat Messages (your existing chat implementation)
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

        // Message Input (your existing input)
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
          'This health assistant provides general information about maternal and child health care. You can browse categories for quick answers or ask specific questions. For medical emergencies, always consult your healthcare provider.',
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

// Data Models
class HealthCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  HealthCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class PredefinedQuestion {
  final String question;
  final String answer;

  PredefinedQuestion({
    required this.question,
    required this.answer,
  });
}

// Your existing ChatMessage and ChatBubble classes remain the same
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