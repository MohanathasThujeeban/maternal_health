package com.example.maternalcare.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.Random;

@Service
public class MaternalCareNotificationService {
    
    private static final Logger logger = LoggerFactory.getLogger(MaternalCareNotificationService.class);
    
    private final Random random = new Random();
    
    // Inspirational quotes for mothers
    private final List<NotificationMessage> maternalQuotes = Arrays.asList(
        new NotificationMessage("💝 Motherhood Quote", "Being a mother is learning about strengths you didn't know you had. You're stronger than you think! 💪"),
        new NotificationMessage("🌟 Daily Inspiration", "A baby is born with a need to be loved - and never outgrows it. Your love makes all the difference. 💕"),
        new NotificationMessage("🌸 Mom Power", "The days are long, but the years are short. Cherish every moment with your little one. ⏰"),
        new NotificationMessage("💖 Beautiful Journey", "Motherhood: All love begins and ends there. You are creating a beautiful story. 📖"),
        new NotificationMessage("🌈 Strength & Love", "A mother's love is the fuel that enables a normal human being to do the impossible. 🚀"),
        new NotificationMessage("🌺 Gentle Reminder", "You are the perfect mother for your child. Trust your instincts and believe in yourself. ✨"),
        new NotificationMessage("💫 Precious Moments", "The love between a mother and child is forever. Every day is a gift. 🎁"),
        new NotificationMessage("🌻 Amazing Mom", "You're not just raising a baby, you're raising a future adult. Your care matters so much! 🌱")
    );
    
    // Health tips for mothers
    private final List<NotificationMessage> healthTips = Arrays.asList(
        new NotificationMessage("💧 Hydration Reminder", "Remember to drink plenty of water today! Staying hydrated is essential for you and your baby. 🥤"),
        new NotificationMessage("🥗 Nutrition Tip", "Include iron-rich foods like spinach, lentils, and lean meat in your diet today. Your body needs it! 🍃"),
        new NotificationMessage("😴 Rest Reminder", "Rest when your baby rests. Your body is doing amazing work and needs recovery time. 💤"),
        new NotificationMessage("🚶‍♀️ Gentle Exercise", "A short 10-minute walk can boost your mood and energy. Fresh air is great for both of you! 🌤️"),
        new NotificationMessage("🧘‍♀️ Mental Health", "Take 5 minutes today for deep breathing. Your mental health is just as important as physical health. 🌸"),
        new NotificationMessage("🥛 Calcium Boost", "Don't forget your daily calcium! Milk, yogurt, or cheese will help keep your bones strong. 🦴"),
        new NotificationMessage("🌅 Morning Routine", "Start your day with a healthy breakfast. You and your baby need good nutrition! 🍳"),
        new NotificationMessage("📱 Screen Break", "Take regular breaks from screens. Your eyes and mind need rest too! 👀")
    );
    
    // Baby care tips
    private final List<NotificationMessage> babyCareMessages = Arrays.asList(
        new NotificationMessage("👶 Baby Development", "Talk to your baby often! Your voice helps their brain development and strengthens your bond. 🗣️"),
        new NotificationMessage("🤱 Feeding Time", "Every feeding is a bonding opportunity. Relax and enjoy these special moments together. 💕"),
        new NotificationMessage("😊 Baby's Smile", "Your baby's first social smile usually happens around 6-8 weeks. Look forward to this magical moment! ✨"),
        new NotificationMessage("🎵 Music for Baby", "Soft music or lullabies can be soothing for your baby and help with sleep. Try it tonight! 🎶"),
        new NotificationMessage("📚 Reading Benefits", "It's never too early to read to your baby. Your voice is the most beautiful sound to them! 📖"),
        new NotificationMessage("🛁 Bath Time Fun", "Bath time can be bonding time! Keep the water warm and your touch gentle. 🫧"),
        new NotificationMessage("💤 Sleep Schedule", "Babies sleep a lot in the first months - up to 16 hours a day. This is completely normal! 😴"),
        new NotificationMessage("🤗 Skin-to-Skin", "Skin-to-skin contact helps regulate your baby's temperature and heart rate. It's magical! 💝")
    );
    
    // Appointment and medical reminders
    private final List<NotificationMessage> medicalReminders = Arrays.asList(
        new NotificationMessage("🩺 Check-up Reminder", "Remember to schedule your regular prenatal or postnatal check-up. Your health matters! 📅"),
        new NotificationMessage("💊 Vitamin Reminder", "Have you taken your prenatal vitamins today? Your body and baby need those nutrients! 💊"),
        new NotificationMessage("🌡️ Temperature Check", "Monitor your baby's room temperature. The ideal range is 68-72°F (20-22°C). 🌡️"),
        new NotificationMessage("🩸 Iron Levels", "If you're feeling tired, mention it to your doctor. Low iron is common but treatable! ⚡"),
        new NotificationMessage("🤒 Warning Signs", "Trust your instincts! If something doesn't feel right, don't hesitate to contact your healthcare provider. ☎️"),
        new NotificationMessage("💉 Vaccination Schedule", "Keep track of your baby's vaccination schedule. Immunizations protect their health! 🛡️"),
        new NotificationMessage("👂 Hearing Test", "Newborn hearing screening is important for early detection. Ask your doctor about it! 👂"),
        new NotificationMessage("👀 Vision Development", "Your baby's vision develops gradually. They can see your face best at 8-12 inches away! 👁️")
    );
    
    /**
     * Send a random daily tip notification to a user
     */
    public void sendDailyTip(String userNic) {
        try {
            NotificationMessage message = getRandomTip();
            
            logger.info("📱 Daily tip for user {}: {} - {}", userNic, message.title, message.body);
            
        } catch (Exception e) {
            logger.error("❌ Error sending daily tip to user {}: {}", userNic, e.getMessage());
        }
    }
    
    /**
     * Send a motivational quote
     */
    public void sendMotivationalQuote(String userNic) {
        try {
            NotificationMessage quote = maternalQuotes.get(random.nextInt(maternalQuotes.size()));
            
            logger.info("💝 Motivational quote for user {}: {} - {}", userNic, quote.title, quote.body);
            
        } catch (Exception e) {
            logger.error("❌ Error sending motivational quote to user {}: {}", userNic, e.getMessage());
        }
    }
    
    /**
     * Send a health tip
     */
    public void sendHealthTip(String userNic) {
        try {
            NotificationMessage tip = healthTips.get(random.nextInt(healthTips.size()));
            
            logger.info("💊 Health tip for user {}: {} - {}", userNic, tip.title, tip.body);
            
        } catch (Exception e) {
            logger.error("❌ Error sending health tip to user {}: {}", userNic, e.getMessage());
        }
    }
    
    /**
     * Send baby care tip
     */
    public void sendBabyCareTip(String userNic) {
        try {
            NotificationMessage tip = babyCareMessages.get(random.nextInt(babyCareMessages.size()));
            
            logger.info("👶 Baby care tip for user {}: {} - {}", userNic, tip.title, tip.body);
            
        } catch (Exception e) {
            logger.error("❌ Error sending baby care tip to user {}: {}", userNic, e.getMessage());
        }
    }
    
    /**
     * Send medical reminder
     */
    public void sendMedicalReminder(String userNic) {
        try {
            NotificationMessage reminder = medicalReminders.get(random.nextInt(medicalReminders.size()));
            
            logger.info("🩺 Medical reminder for user {}: {} - {}", userNic, reminder.title, reminder.body);
            
        } catch (Exception e) {
            logger.error("❌ Error sending medical reminder to user {}: {}", userNic, e.getMessage());
        }
    }
    
    /**
     * Get a random tip from all categories
     */
    private NotificationMessage getRandomTip() {
        List<NotificationMessage> allMessages = Arrays.asList(
            maternalQuotes.get(random.nextInt(maternalQuotes.size())),
            healthTips.get(random.nextInt(healthTips.size())),
            babyCareMessages.get(random.nextInt(babyCareMessages.size())),
            medicalReminders.get(random.nextInt(medicalReminders.size()))
        );
        
        return allMessages.get(random.nextInt(allMessages.size()));
    }
    
    /**
     * Send morning inspiration (can be scheduled)
     */
    @Scheduled(cron = "0 0 8 * * ?") // Every day at 8 AM
    public void sendMorningInspiration() {
        // In a real app, you would get all active users from database
        // For now, we'll just log that it would run
        logger.info("🌅 Morning inspiration scheduled task triggered");
        // sendMotivationalQuote("all-active-users");
    }
    
    /**
     * Send evening health tip (can be scheduled)
     */
    @Scheduled(cron = "0 0 19 * * ?") // Every day at 7 PM
    public void sendEveningHealthTip() {
        logger.info("🌙 Evening health tip scheduled task triggered");
        // sendHealthTip("all-active-users");
    }
    
    /**
     * Helper class for notification messages
     */
    private static class NotificationMessage {
        final String title;
        final String body;
        
        NotificationMessage(String title, String body) {
            this.title = title;
            this.body = body;
        }
    }
}
