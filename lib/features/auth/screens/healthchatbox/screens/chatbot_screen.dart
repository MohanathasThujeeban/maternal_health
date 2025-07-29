// lib/screens/chatbot_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/question.dart';
import '../models/message.dart';
import '../data/chatbot_data.dart';

enum ChatbotView { categories, questions, chat }

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  ChatbotView currentView = ChatbotView.categories;
  HealthCategory? selectedCategory;
  List<ChatMessage> messages = [];
  bool isTyping = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState(); 
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectCategory(HealthCategory category) {
    setState(() {
      selectedCategory = category;
      currentView = ChatbotView.questions;
    });
  }

  void _selectQuestion(HealthQuestion question) {
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: question.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages = [userMessage];
      currentView = ChatbotView.chat;
      isTyping = true;
    });

    // Simulate bot response delay
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        final botMessage = ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: question.answer,
          isUser: false,
          timestamp: DateTime.now(),
        );

        setState(() {
          messages.add(botMessage);
          isTyping = false;
        });
      }
    });
  }

  void _backToCategories() {
    setState(() {
      currentView = ChatbotView.categories;
      selectedCategory = null;
      messages.clear();
    });
  }

  void _backToQuestions() {
    setState(() {
      currentView = ChatbotView.questions;
      messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.blue.shade50,
              const Color.fromARGB(255, 171, 220, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCurrentView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case ChatbotView.categories:
        return _buildCategoriesView();
      case ChatbotView.questions:
        return _buildQuestionsView();
      case ChatbotView.chat:
        return _buildChatView();
    }
  }

  Widget _buildCategoriesView() {
    final categories = ChatbotData.getCategories();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 20),
          // Header
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.lightBlueAccent],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Health Assistant',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Get instant answers to your maternal and child health questions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 40),
          
          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
    );
  }

  Widget _buildCategoryCard(HealthCategory category) {
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
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
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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

  Widget _buildQuestionsView() {
    final questions = ChatbotData.getQuestionsForCategory(selectedCategory!.id);

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                onPressed: _backToCategories,
                icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedCategory!.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  selectedCategory!.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                selectedCategory!.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        
        // Questions List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionCard(question);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(HealthQuestion question) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () => _selectQuestion(question),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              question.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Chat Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _backToQuestions,
                icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedCategory!.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  selectedCategory!.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selectedCategory!.name} Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'Always here to help',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Messages
        Expanded(
          child: Container(
            color: Colors.grey[50],
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
        ),
        
        // Bottom Actions
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _backToQuestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory!.color,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ask Another Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.smart_toy, size: 16, color: Colors.grey[600]),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? selectedCategory!.color : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser ? Radius.circular(16) : Radius.zero,
                  bottomRight: message.isUser ? Radius.zero : Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isUser ? Colors.white : Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: selectedCategory!.color.withOpacity(0.2),
              child: Icon(Icons.person, size: 16, color: selectedCategory!.color),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.smart_toy, size: 16, color: Colors.grey[600]),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: Radius.zero,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4),
                _buildTypingDot(200),
                SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}