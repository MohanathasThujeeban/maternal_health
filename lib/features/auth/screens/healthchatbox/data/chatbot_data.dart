import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/question.dart';

class ChatbotData {
  static List<HealthCategory> getCategories() {
    return [
      HealthCategory(
        id: 'pregnancy',
        name: 'Pregnancy Care',
        icon: Icons.favorite,
        color: Colors.pink,
        description: 'Prenatal care, symptoms, and wellness tips',
      ),
      HealthCategory(
        id: 'childcare',
        name: 'Child Care',
        icon: Icons.child_care,
        color: Colors.blue,
        description: 'Newborn care, development milestones',
      ),
      HealthCategory(
        id: 'nutrition',
        name: 'Nutrition',
        icon: Icons.restaurant,
        color: Colors.green,
        description: 'Diet plans, healthy eating guidelines',
      ),
      HealthCategory(
        id: 'vaccination',
        name: 'Vaccination',
        icon: Icons.health_and_safety,
        color: Colors.purple,
        description: 'Immunization schedules and information',
      ),
    ];
  }

  static List<HealthQuestion> getQuestions() {
    return [
      // Pregnancy Questions
      HealthQuestion(
        id: 1,
        categoryId: 'pregnancy',
        text: "What should I eat during pregnancy?",
        answer: "Focus on a balanced diet rich in folate, iron, calcium, and protein. Include leafy greens, lean meats, dairy products, whole grains, and fruits. Avoid raw fish, unpasteurized products, and limit caffeine to 200mg per day.",
      ),
      HealthQuestion(
        id: 2,
        categoryId: 'pregnancy',
        text: "How much weight should I gain?",
        answer: "Weight gain depends on your pre-pregnancy BMI:\n• Normal weight (18.5-24.9): 25-35 lbs\n• Underweight: 28-40 lbs\n• Overweight: 15-25 lbs\n• Obese: 11-20 lbs\n\nConsult your healthcare provider for personalized advice.",
      ),
      HealthQuestion(
        id: 3,
        categoryId: 'pregnancy',
        text: "What are normal pregnancy symptoms?",
        answer: "Common symptoms include:\n• Morning sickness (nausea/vomiting)\n• Fatigue and tiredness\n• Breast tenderness\n• Frequent urination\n• Mood changes\n• Food aversions or cravings\n\nContact your doctor if symptoms are severe or concerning.",
      ),
      HealthQuestion(
        id: 4,
        categoryId: 'pregnancy',
        text: "When should I contact my doctor?",
        answer: "Contact immediately for:\n• Severe abdominal pain\n• Heavy bleeding\n• Severe headaches\n• Vision changes\n• Persistent vomiting\n• Decreased fetal movement after 28 weeks\n• Signs of preterm labor\n• High fever or chills",
      ),

      // Child Care Questions
      HealthQuestion(
        id: 5,
        categoryId: 'childcare',
        text: "How often should I feed my newborn?",
        answer: "Newborns typically feed every 2-3 hours, or 8-12 times per day. Breastfed babies may feed more frequently. Watch for hunger cues like:\n• Rooting or searching for breast\n• Sucking motions\n• Fussiness or crying\n• Moving hands to mouth",
      ),
      HealthQuestion(
        id: 6,
        categoryId: 'childcare',
        text: "When do babies start sleeping through the night?",
        answer: "Most babies can sleep through the night (6-8 hours) by 3-6 months, but every baby is different. Tips for better sleep:\n• Establish bedtime routine\n• Safe sleep practices (back sleeping)\n• Consistent sleep environment\n• Day/night differentiation",
      ),
      HealthQuestion(
        id: 7,
        categoryId: 'childcare',
        text: "What are important developmental milestones?",
        answer: "Key milestones by age:\n• 2 months: Social smiles, tracks objects\n• 4 months: Holds head up, laughs\n• 6 months: Sits with support, babbles\n• 9 months: Crawls, says 'mama/dada'\n• 12 months: First steps, first words\n• 18 months: Walks independently, 10+ words",
      ),
      HealthQuestion(
        id: 8,
        categoryId: 'childcare',
        text: "How to handle excessive baby crying?",
        answer: "Check if baby:\n• Is hungry or needs feeding\n• Needs diaper change\n• Is tired or overstimulated\n• Is uncomfortable (too hot/cold)\n\nSoothing techniques:\n• Swaddling\n• Gentle rocking or bouncing\n• White noise or soft music\n• Skin-to-skin contact\n\nIf crying persists for hours, consult pediatrician.",
      ),

      // Nutrition Questions
      HealthQuestion(
        id: 9,
        categoryId: 'nutrition',
        text: "What foods should I avoid while breastfeeding?",
        answer: "Generally, most foods are safe while breastfeeding:\n• Limit caffeine to 1-2 cups coffee/day\n• Avoid alcohol or pump and dump\n• Limit high-mercury fish\n• Watch for baby's reactions to spicy foods\n\nIf baby shows sensitivity (fussiness, rash), consider temporarily eliminating potential allergens.",
      ),
      HealthQuestion(
        id: 10,
        categoryId: 'nutrition',
        text: "When can I introduce solid foods?",
        answer: "Start introducing solids around 6 months when baby:\n• Can sit up with minimal support\n• Has good head and neck control\n• Shows interest in food\n• Can move food to back of mouth\n\nStart with single-ingredient foods like iron-fortified cereal or pureed vegetables.",
      ),
      HealthQuestion(
        id: 11,
        categoryId: 'nutrition',
        text: "What are good first foods for babies?",
        answer: "Recommended first foods:\n• Iron-fortified baby cereal\n• Pureed vegetables (sweet potato, carrots, peas)\n• Pureed fruits (banana, apple, pear)\n• Well-cooked, mashed legumes\n• Avocado\n\nIntroduce one food at a time for 3-5 days to watch for allergic reactions.",
      ),
      HealthQuestion(
        id: 12,
        categoryId: 'nutrition',
        text: "How much water should my toddler drink?",
        answer: "Daily fluid needs for toddlers (1-3 years):\n• About 4 cups (32 oz) total fluids\n• This includes milk and other beverages\n• Offer water between meals\n• Limit juice to 4-6 oz per day of 100% fruit juice\n• Milk: 16-24 oz per day after age 1",
      ),

      // Vaccination Questions
      HealthQuestion(
        id: 13,
        categoryId: 'vaccination',
        text: "What vaccines does my baby need?",
        answer: "Key vaccines by schedule:\n• Birth: Hepatitis B\n• 2 months: DTaP, Hib, PCV13, IPV, RV\n• 4 months: DTaP, Hib, PCV13, IPV, RV\n• 6 months: DTaP, Hib, PCV13, IPV, RV\n• 12-15 months: MMR, Varicella, PCV13\n• 15-18 months: DTaP, Hib\n\nFollow your pediatrician's recommended schedule.",
      ),
      HealthQuestion(
        id: 14,
        categoryId: 'vaccination',
        text: "Are vaccines safe for my baby?",
        answer: "Yes, vaccines are thoroughly tested for safety and effectiveness:\n• Undergo rigorous clinical trials\n• Continuously monitored for safety\n• Benefits far outweigh risks\n• Serious side effects are extremely rare\n\nCommon mild reactions: slight fever, soreness at injection site, mild fussiness.",
      ),
      HealthQuestion(
        id: 15,
        categoryId: 'vaccination',
        text: "What if my child misses a vaccination?",
        answer: "If your child misses vaccines:\n• Contact your healthcare provider\n• No need to restart the entire series\n• Provider will create catch-up schedule\n• Based on child's current age\n• Important to catch up as soon as possible\n\nDelayed vaccines still provide protection once given.",
      ),
      HealthQuestion(
        id: 16,
        categoryId: 'vaccination',
        text: "Can vaccines be given together?",
        answer: "Yes, multiple vaccines can be safely given at the same visit:\n• Doesn't increase side effects\n• Doesn't reduce effectiveness\n• Actually protects your child sooner\n• Reduces number of clinic visits\n• Recommended by pediatricians\n\nSeparate needles and injection sites are used.",
      ),
    ];
  }

  static List<HealthQuestion> getQuestionsForCategory(String categoryId) {
    return getQuestions().where((q) => q.categoryId == categoryId).toList();
  }
}
