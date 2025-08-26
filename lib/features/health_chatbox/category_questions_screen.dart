import 'package:flutter/material.dart';
import 'question_answer_screen.dart';
import 'models.dart';

class CategoryQuestionsScreen extends StatelessWidget {
  final HealthCategory category;
  final List<PredefinedQuestion> questions;

  const CategoryQuestionsScreen({
    super.key,
    required this.category,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.title,
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: category.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5F2), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${questions.length} Questions Available',
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 14,
                      color: category.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Questions List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionAnswerScreen(
                                question: question.question,
                                answer: question.answer,
                                categoryTitle: category.title,
                                categoryColor: category.color,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.help_outline,
                                  color: category.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Question ${index + 1}',
                                      style: TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontSize: 12,
                                        color: category.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      question.question,
                                      style: const TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2E7D5A),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey.shade600,
                                  size: 16,
                                ),
                              ),
                            ],
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
    );
  }
}
