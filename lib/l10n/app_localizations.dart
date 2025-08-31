import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Maternal Health'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @babyGrowth.
  ///
  /// In en, this message translates to:
  /// **'Baby Growth'**
  String get babyGrowth;

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Sarah!'**
  String get welcome;

  /// No description provided for @healthyBaby.
  ///
  /// In en, this message translates to:
  /// **'You have a healthy baby!'**
  String get healthyBaby;

  /// No description provided for @babyStats.
  ///
  /// In en, this message translates to:
  /// **'Baby Stats'**
  String get babyStats;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @quickQuestions.
  ///
  /// In en, this message translates to:
  /// **'Quick Questions'**
  String get quickQuestions;

  /// No description provided for @isWeightNormal.
  ///
  /// In en, this message translates to:
  /// **'Is my baby\'s weight normal?'**
  String get isWeightNormal;

  /// No description provided for @introduceSolidFoods.
  ///
  /// In en, this message translates to:
  /// **'When should I introduce solid foods?'**
  String get introduceSolidFoods;

  /// No description provided for @howMuchSleep.
  ///
  /// In en, this message translates to:
  /// **'How much sleep does my baby need?'**
  String get howMuchSleep;

  /// No description provided for @whatVaccinesDue.
  ///
  /// In en, this message translates to:
  /// **'What vaccines are due next?'**
  String get whatVaccinesDue;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @weightCheckup.
  ///
  /// In en, this message translates to:
  /// **'Weight checkup completed'**
  String get weightCheckup;

  /// No description provided for @vaccinationReminder.
  ///
  /// In en, this message translates to:
  /// **'Vaccination reminder'**
  String get vaccinationReminder;

  /// No description provided for @feedingTime.
  ///
  /// In en, this message translates to:
  /// **'Feeding time logged'**
  String get feedingTime;

  /// No description provided for @sleepTracked.
  ///
  /// In en, this message translates to:
  /// **'Sleep pattern tracked'**
  String get sleepTracked;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @weekAgo.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get weekAgo;

  /// No description provided for @growthChart.
  ///
  /// In en, this message translates to:
  /// **'Growth Chart'**
  String get growthChart;

  /// No description provided for @weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get weightProgress;

  /// No description provided for @heightProgress.
  ///
  /// In en, this message translates to:
  /// **'Height Progress'**
  String get heightProgress;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @percentile.
  ///
  /// In en, this message translates to:
  /// **'75th percentile'**
  String get percentile;

  /// No description provided for @healthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get healthStatus;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @medicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medicalRecords;

  /// No description provided for @vaccinationHistory.
  ///
  /// In en, this message translates to:
  /// **'Vaccination History'**
  String get vaccinationHistory;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @noAllergies.
  ///
  /// In en, this message translates to:
  /// **'No known allergies'**
  String get noAllergies;

  /// No description provided for @noMedications.
  ///
  /// In en, this message translates to:
  /// **'No current medications'**
  String get noMedications;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No description provided for @doctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visit'**
  String get doctorVisit;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @checkup.
  ///
  /// In en, this message translates to:
  /// **'Checkup'**
  String get checkup;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @healthAssistant.
  ///
  /// In en, this message translates to:
  /// **'Health Assistant'**
  String get healthAssistant;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a health question...'**
  String get askQuestion;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @sinhala.
  ///
  /// In en, this message translates to:
  /// **'සිංහල'**
  String get sinhala;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @nextCheckup.
  ///
  /// In en, this message translates to:
  /// **'Next Checkup'**
  String get nextCheckup;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @weightToday.
  ///
  /// In en, this message translates to:
  /// **'Weight Today'**
  String get weightToday;

  /// No description provided for @vaccinations.
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get vaccinations;

  /// No description provided for @welcomeMom.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Mom! 💕'**
  String get welcomeMom;

  /// No description provided for @babyAge.
  ///
  /// In en, this message translates to:
  /// **'Baby\'s Age'**
  String get babyAge;

  /// No description provided for @maternalCare.
  ///
  /// In en, this message translates to:
  /// **'Maternal Care'**
  String get maternalCare;

  /// No description provided for @motherPortal.
  ///
  /// In en, this message translates to:
  /// **'Mother Portal'**
  String get motherPortal;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you and your baby feeling today?'**
  String get howAreYouFeeling;

  /// No description provided for @babyCare.
  ///
  /// In en, this message translates to:
  /// **'👶 Baby Care'**
  String get babyCare;

  /// No description provided for @trackBabyGrowth.
  ///
  /// In en, this message translates to:
  /// **'Track your baby\'s growth and development'**
  String get trackBabyGrowth;

  /// No description provided for @babyGrowthChart.
  ///
  /// In en, this message translates to:
  /// **'Baby Growth Chart'**
  String get babyGrowthChart;

  /// No description provided for @trackWeightHeight.
  ///
  /// In en, this message translates to:
  /// **'Track weight, height, and development'**
  String get trackWeightHeight;

  /// No description provided for @vaccinationSchedule.
  ///
  /// In en, this message translates to:
  /// **'View vaccination schedule and records'**
  String get vaccinationSchedule;

  /// No description provided for @healthMedical.
  ///
  /// In en, this message translates to:
  /// **'🏥 Health & Medical'**
  String get healthMedical;

  /// No description provided for @manageHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'Manage your health records and appointments'**
  String get manageHealthRecords;

  /// No description provided for @viewMedicalHistory.
  ///
  /// In en, this message translates to:
  /// **'View medical history and reports'**
  String get viewMedicalHistory;

  /// No description provided for @scheduleManageAppointments.
  ///
  /// In en, this message translates to:
  /// **'View, schedule and manage appointments'**
  String get scheduleManageAppointments;

  /// No description provided for @thiriposaRecords.
  ///
  /// In en, this message translates to:
  /// **'Thiriposa Records'**
  String get thiriposaRecords;

  /// No description provided for @trackNutritionSupplements.
  ///
  /// In en, this message translates to:
  /// **'Track nutrition supplement records'**
  String get trackNutritionSupplements;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'⚡ Quick Actions'**
  String get quickActions;

  /// No description provided for @frequentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Frequently used features'**
  String get frequentlyUsed;

  /// No description provided for @healthChat.
  ///
  /// In en, this message translates to:
  /// **'Health Chat'**
  String get healthChat;

  /// No description provided for @askHealthQuestions.
  ///
  /// In en, this message translates to:
  /// **'Ask health questions anytime'**
  String get askHealthQuestions;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @quickEmergencyAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access to emergency services'**
  String get quickEmergencyAccess;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @emergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @yourRegisteredHospital.
  ///
  /// In en, this message translates to:
  /// **'Your registered hospital'**
  String get yourRegisteredHospital;

  /// No description provided for @yourDoctor.
  ///
  /// In en, this message translates to:
  /// **'Your Doctor'**
  String get yourDoctor;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @babyGrowthChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby\'s Growth Chart'**
  String get babyGrowthChartTitle;

  /// No description provided for @currentStats.
  ///
  /// In en, this message translates to:
  /// **'Current Stats'**
  String get currentStats;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'change'**
  String get change;

  /// No description provided for @headCircumference.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference'**
  String get headCircumference;

  /// No description provided for @growthChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth Chart'**
  String get growthChartTitle;

  /// No description provided for @interactiveChart.
  ///
  /// In en, this message translates to:
  /// **'Interactive chart will be displayed here'**
  String get interactiveChart;

  /// No description provided for @recentMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Recent Measurements'**
  String get recentMeasurements;

  /// No description provided for @healthyGrowth.
  ///
  /// In en, this message translates to:
  /// **'Healthy growth, on track'**
  String get healthyGrowth;

  /// No description provided for @goodProgress.
  ///
  /// In en, this message translates to:
  /// **'Good progress'**
  String get goodProgress;

  /// No description provided for @normalDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Normal development'**
  String get normalDevelopment;

  /// No description provided for @healthRecordsVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Health Records & Vaccinations'**
  String get healthRecordsVaccinations;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @vaccinationProgress.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Progress'**
  String get vaccinationProgress;

  /// No description provided for @vaccinationsCompleted.
  ///
  /// In en, this message translates to:
  /// **'vaccinations completed'**
  String get vaccinationsCompleted;

  /// No description provided for @recentVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Recent Vaccinations'**
  String get recentVaccinations;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get dueSoon;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointmentsFound;

  /// No description provided for @tapScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Tap the Schedule button to book your first appointment'**
  String get tapScheduleButton;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelAppointment;

  /// No description provided for @cancelConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment? This action cannot be undone.'**
  String get cancelConfirmation;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancelAppointment;

  /// No description provided for @doctorConsultation.
  ///
  /// In en, this message translates to:
  /// **'Doctor Consultation'**
  String get doctorConsultation;

  /// No description provided for @midwifeConsultation.
  ///
  /// In en, this message translates to:
  /// **'Midwife Consultation'**
  String get midwifeConsultation;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes:'**
  String get additionalNotes;

  /// No description provided for @doctorNotes.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s Notes:'**
  String get doctorNotes;

  /// No description provided for @cancelAppointmentButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelAppointmentButton;

  /// No description provided for @askAnythingBaby.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your baby\'s health!'**
  String get askAnythingBaby;

  /// No description provided for @helpWithFeeding.
  ///
  /// In en, this message translates to:
  /// **'I can help with feeding, sleep, development, and general health questions.'**
  String get helpWithFeeding;

  /// No description provided for @babyRecords.
  ///
  /// In en, this message translates to:
  /// **'Baby Records'**
  String get babyRecords;

  /// No description provided for @babyRecordsDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete baby records with PDF export'**
  String get babyRecordsDescription;

  /// No description provided for @noVaccinationRecords.
  ///
  /// In en, this message translates to:
  /// **'No vaccination records found'**
  String get noVaccinationRecords;

  /// No description provided for @vaccinationRecordsDescription.
  ///
  /// In en, this message translates to:
  /// **'Vaccination records will appear here once they are added by your healthcare provider'**
  String get vaccinationRecordsDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
