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
      question: "What should a pregnant woman avoid to maintain good health during pregnancy?",
      answer: "A pregnant woman should avoid smoking, alcohol, betel chewing, and drugs. These habits are harmful to both the mother and the unborn baby.",
    ),
    PredefinedQuestion(
      question: "Why is regular clinic attendance important during pregnancy?",
      answer: "Regular clinics help monitor the health of both mother and baby. They also ensure timely vaccinations, nutritional advice, and detection of complications.",
    ),
    PredefinedQuestion(
      question: "What are important hygiene practices a pregnant mother should follow?",
      answer: "She should bathe daily, wear clean clothes, maintain oral hygiene, and keep fingernails short and clean to avoid infections.",
    ),
    PredefinedQuestion(
      question: "How much rest should a pregnant woman get?",
      answer: "She should get about 8–10 hours of sleep daily, including short naps during the day, to avoid fatigue and support baby development.",
    ),
    PredefinedQuestion(
      question: "Can a pregnant woman work or do household chores?",
      answer: "Yes, she can do light work and daily household chores unless advised otherwise by a doctor. Heavy lifting and excessive standing should be avoided.",
    ),
    PredefinedQuestion(
      question: "What danger signs during pregnancy require immediate medical attention?",
      answer: "Bleeding, severe abdominal pain, swollen hands/face, blurry vision, persistent vomiting, or reduced fetal movements should be reported to a clinic immediately.",
    ),
    PredefinedQuestion(
      question: "Why should iron and folic acid tablets be taken during pregnancy?",
      answer: "They prevent anemia and support the baby’s brain and spine development. Tablets should be taken daily as prescribed by the midwife.",
    ),
    PredefinedQuestion(
      question: "What is the importance of tetanus vaccination during pregnancy?",
      answer: "Tetanus vaccines protect both mother and newborn from infections that can occur during childbirth. They are given as part of the routine clinic schedule.",
    ),
    PredefinedQuestion(
      question: "Can pregnant women travel?",
      answer: "Travel is allowed in early pregnancy and later stages if the doctor approves. However, long journeys, bumpy rides, or standing in crowded vehicles should be avoided.",
    ),
    PredefinedQuestion(
      question: "What are healthy eating habits for a pregnant woman?",
      answer: "She should eat frequent, small meals rich in vegetables, fruits, grains, fish, eggs, and milk, and avoid fatty, fried, and sugary foods.",
    ),
    PredefinedQuestion(
      question: "Should a pregnant mother take herbal remedies or non-prescribed medication?",
      answer: "No. Only medications prescribed by a qualified doctor should be taken during pregnancy, as others may harm the baby.",
    ),
  ],
  'childcare': [
    PredefinedQuestion(
      question: "How should a newborn be fed in the first few months?",
      answer: "The baby should be exclusively breastfed for the first six months. No water, formula, or solids should be given during this period.",
    ),
    PredefinedQuestion(
      question: "How can a mother ensure her baby is getting enough milk?",
      answer: "If the baby urinates 6–8 times a day, gains weight steadily, sleeps well, and feeds actively, milk intake is sufficient.",
    ),
    PredefinedQuestion(
      question: "What are common positions for safe breastfeeding?",
      answer: "The baby’s head should be higher than the body, the body facing the mother, and the entire nipple and areola inside the baby’s mouth.",
    ),
    PredefinedQuestion(
      question: "How should a baby be bathed and cleaned?",
      answer: "Use warm water and mild soap. Gently clean underarms, neck folds, and diaper area. Dry the baby thoroughly after each bath.",
    ),
    PredefinedQuestion(
      question: "How should the baby’s umbilical cord be cared for?",
      answer: "Keep it dry and clean. Do not cover with cloth or apply any substances. Let it fall off naturally. If there’s pus or a bad smell, seek medical help.",
    ),
    PredefinedQuestion(
      question: "How should a baby be held properly?",
      answer: "Always support the neck and head. Hold the baby close to your chest, especially when feeding or carrying.",
    ),
    PredefinedQuestion(
      question: "What should be done if a baby has a fever or refuses to feed?",
      answer: "The baby should be taken to the hospital or clinic immediately. Delaying care can cause complications.",
    ),
    PredefinedQuestion(
      question: "How often should a baby’s clothes and bedding be changed?",
      answer: "Daily, or immediately if soiled. Cleanliness prevents rashes and infections.",
    ),
    PredefinedQuestion(
      question: "How can mothers prevent diaper rash?",
      answer: "Change diapers often, let the baby go diaper-free when possible, clean with warm water, and apply a safe barrier cream if needed.",
    ),
    PredefinedQuestion(
      question: "Is it safe to take a baby outside?",
      answer: "Yes, after 6 weeks, in mild weather. Avoid crowds, smoke, and sick people. Dress the baby appropriately for the weather.",
    ),
  ],
  'nutrition': [
    PredefinedQuestion(
      question: "What are the important nutrients a pregnant woman needs?",
      answer: "Iron, folic acid, calcium, protein, and vitamins are essential. These support the baby’s growth and prevent health issues like anemia and weak bones.",
    ),
    PredefinedQuestion(
      question: "What foods are good sources of iron during pregnancy?",
      answer: "Green leafy vegetables, lentils, red meat, fish, eggs, and iron-fortified cereals are excellent sources.",
    ),
    PredefinedQuestion(
      question: "Why is it important for pregnant women to eat small, frequent meals?",
      answer: "It helps reduce nausea, heartburn, and maintains steady energy levels for both mother and baby.",
    ),
    PredefinedQuestion(
      question: "What foods should a pregnant woman avoid?",
      answer: "Avoid raw fish, undercooked meat, unpasteurized milk, alcohol, too much salt, and sugary drinks.",
    ),
    PredefinedQuestion(
      question: "How can a mother maintain hydration during pregnancy?",
      answer: "Drink at least 8–10 glasses of clean water daily, especially in hot weather or after physical activity.",
    ),
    PredefinedQuestion(
      question: "When should solid foods be introduced to a baby?",
      answer: "At 6 months. Begin with mashed vegetables, rice, lentils, and gradually introduce more textures and types.",
    ),
    PredefinedQuestion(
      question: "What are signs a baby is ready for solid food?",
      answer: "When the baby can sit with support, shows interest in food, and doesn’t push food out with the tongue.",
    ),
    PredefinedQuestion(
      question: "What types of food should be avoided when starting solids?",
      answer: "Avoid honey, salt, sugar, whole nuts, spicy food, and foods that may cause choking.",
    ),
    PredefinedQuestion(
      question: "How should food be prepared for babies?",
      answer: "Food should be clean, well-cooked, soft, and mashed or pureed. Use clean utensils and wash hands before preparation.",
    ),
    PredefinedQuestion(
      question: "How many meals should a child have after starting solids?",
      answer: "At 6–8 months: 2–3 meals + 1 snack. At 9–11 months: 3–4 meals + 1–2 snacks per day along with breastfeeding.",
    ),
  ],
  'vaccination': [
    PredefinedQuestion(
      question: "What vaccines are given at birth in Sri Lanka?",
      answer: "BCG (for tuberculosis) and OPV (Oral Polio Vaccine) are given at birth.",
    ),
    PredefinedQuestion(
      question: "When are DTP vaccines administered?",
      answer: "At 2 months, 4 months, and 6 months as part of the infant immunization schedule.",
    ),
    PredefinedQuestion(
      question: "Are vaccines safe for babies?",
      answer: "Yes. They are thoroughly tested and protect against serious diseases. Side effects are usually mild and temporary.",
    ),
    PredefinedQuestion(
      question: "What are common side effects after a baby receives vaccines?",
      answer: "Mild fever, swelling at injection site, and crankiness. These usually disappear in 1–2 days.",
    ),
    PredefinedQuestion(
      question: "What should be done if a baby misses a vaccine?",
      answer: "Visit the nearest clinic or MOH office immediately. Missed vaccines can often be given later.",
    ),
    PredefinedQuestion(
      question: "Are vaccines free in government clinics in Sri Lanka?",
      answer: "Yes. All vaccines in the national schedule are provided free of charge at government health facilities.",
    ),
    PredefinedQuestion(
      question: "Is vaccination compulsory?",
      answer: "It is strongly recommended by the Ministry of Health. Most schools require proof of vaccination for admission.",
    ),
    PredefinedQuestion(
      question: "Can a sick baby be vaccinated?",
      answer: "Mild colds or coughs are not a reason to delay vaccination. However, if the baby has a high fever or serious illness, consult a doctor first.",
    ),
    PredefinedQuestion(
      question: "Why is it important to complete the full vaccination schedule?",
      answer: "Full protection is only achieved after all doses. Partial vaccination may not prevent illness effectively.",
    ),
  ],
  'other': [
    PredefinedQuestion(
      question: "What should a mother do if she forgets her clinic date?",
      answer: "She should contact her midwife or visit the nearest MOH clinic immediately to reschedule and avoid missing important checkups or vaccinations.",
    ),
    PredefinedQuestion(
      question: "How can a mother register her pregnancy?",
      answer: "Visit the nearest MOH office or inform the area midwife. Early registration helps track pregnancy progress and ensure proper medical care.",
    ),
    PredefinedQuestion(
      question: "What records should a mother maintain during pregnancy and after childbirth?",
      answer: "She should keep the pregnancy record book and child health development record updated with clinic visits, vaccinations, and growth data.",
    ),
    PredefinedQuestion(
      question: "What are some important items to take when visiting the clinic?",
      answer: "Bring the clinic book, previous test reports, vaccination cards, and any prescribed medications.",
    ),
    PredefinedQuestion(
      question: "What are the responsibilities of the area midwife?",
      answer: "The midwife provides home visits, monitors maternal and child health, offers advice, gives supplements, and updates records regularly.",
    ),
    PredefinedQuestion(
      question: "How does the Public Health Inspector (PHI) help during and after pregnancy?",
      answer: "PHIs supervise environmental and community hygiene, ensure vaccination programs, and follow up on public health needs in the area.",
    ),
    PredefinedQuestion(
      question: "How should a family support a pregnant woman or new mother?",
      answer: "Family members should help with chores, ensure the mother gets rest, accompany her to clinics, and support mental well-being.",
    ),
    PredefinedQuestion(
      question: "Why is early childhood development monitoring important?",
      answer: "It helps detect delays in speech, motor skills, or behavior so interventions can begin early to improve outcomes.",
    ),
    PredefinedQuestion(
      question: "What is the importance of birth registration?",
      answer: "It legally recognizes the child, enables school admission, access to healthcare, and social services. It should be done within 42 days of birth.",
    ),
    PredefinedQuestion(
      question: "What signs in a baby indicate a need for urgent medical care?",
      answer: "Signs include poor feeding, lethargy, breathing difficulty, persistent crying, vomiting, diarrhea, or fever. Immediate care is needed.",
    ),
    PredefinedQuestion(
      question: "How can a mother get health advice outside clinic hours?",
      answer: "She can contact the area midwife or use government health hotlines. Emergency services are also available through hospitals.",
    ),
    PredefinedQuestion(
      question: "What are the benefits of home visits by the midwife?",
      answer: "Midwives offer personalized care, monitor home environment, guide mothers on hygiene, breastfeeding, and spot health risks early.",
    ),
    PredefinedQuestion(
      question: "What role does hygiene play in maternal and child health?",
      answer: "Good hygiene prevents infections, improves comfort, and ensures faster recovery after delivery. Clean clothes, food, and surroundings are essential.",
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