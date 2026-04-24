/// All static text strings for Smart Farm Assistant.
/// Centralized here so future localization (Indonesian, Arabic) is easy.
class AppStrings {
  AppStrings._();

  // ── App General ───────────────────────────────────────────────────
  static const String appName         = 'Smart Farm Assistant';
  static const String tagline         = 'Your complete guide to healthier\nlivestock and abundant crops';

  // ── Onboarding ────────────────────────────────────────────────────
  static const String onboarding1Title    = 'What Does This App Do?';
  static const String onboarding1Point1   = 'Helps diagnose common livestock health issues';
  static const String onboarding1Point2   = 'Provides guidance for crop care and protection';

  static const String onboarding2Title    = 'How Can It Help You?';
  static const String onboarding2Point1   = 'Feeding and protection recommendations';
  static const String onboarding2Point2   = 'Early alerts for weather and disease risks';

  static const String onboarding3Title    = 'The Role of Artificial Intelligence';
  static const String onboarding3Body     = 'The smart assistant asks simple questions and provides step-by-step recommendations.';
  static const String enterApp            = 'Enter the App';
  static const String skip                = 'Skip';
  static const String next                = 'Next';
  static const String getStarted          = 'Get Start';

  // ── Auth ──────────────────────────────────────────────────────────
  static const String login               = 'Login';
  static const String loginSubtitle       = 'Sign in to continue';
  static const String register            = 'Create Account';
  static const String registerSubtitle    = 'Join Smart Farm Assistant';
  static const String email               = 'Email';
  static const String password            = 'Password';
  static const String confirmPassword     = 'Confirm Password';
  static const String fullName            = 'Full Name';
  static const String forgotPassword      = 'Forgot Password?';
  static const String logIn               = 'Log In';
  static const String signUp              = 'Sign Up';
  static const String orDivider           = 'or';
  static const String noAccount           = "Don't have an account? ";
  static const String hasAccount          = 'Already have an account? ';
  static const String signUpLink          = 'Sign Up';
  static const String loginLink           = 'Log In';
  static const String logout              = 'Log Out';

  // ── Home ──────────────────────────────────────────────────────────
  static const String homeGreeting        = 'Hello,';
  static const String homeSubtitle        = 'What do you need help with today?';
  static const String quickActions        = 'Quick Actions';

  // ── Bottom Navigation ─────────────────────────────────────────────
  static const String navHome             = 'Home';
  static const String navCrops            = 'Crops';
  static const String navLivestock        = 'Livestock';
  static const String navChat             = 'Chat';
  static const String navProfile          = 'Profile';

  // ── Livestock ─────────────────────────────────────────────────────
  static const String livestockTitle      = 'Livestock Info Collection';
  static const String animalType          = 'Animal Type';
  static const String selectSymptoms      = 'Select Symptoms';
  static const String dateOfBirth         = 'Date of Birth';
  static const String symptomOnset        = 'Symptom Onset';
  static const String analyzeCondition    = 'Analyze Condition';
  static const String analyzing           = 'Analyzing...';

  // Animal types
  static const String sheep               = 'Sheep';
  static const String cow                 = 'Cow';
  static const String goat                = 'Goat';
  static const String hen                 = 'Hen';

  // Symptoms
  static const String fever               = 'Fever';
  static const String lossOfAppetite      = 'Loss of Appetite';
  static const String diarrhea            = 'Diarrhea';
  static const String cough               = 'Cough';
  static const String lethargy            = 'Lethargy';
  static const String weightLoss          = 'Weight Loss';
  static const String skinLesions         = 'Skin Lesions';
  static const String nasal               = 'Nasal Discharge';

  // Age options
  static const String under1Year          = 'Under 1 year';
  static const String under5Years         = 'Under 5 years';
  static const String over5Years          = 'Over 5 years';

  // Onset options
  static const String lessThan3Days       = 'Less than 3 days';
  static const String under1Week          = 'Under 1 week';
  static const String overAWeek           = 'Over a week';

  // Result screen
  static const String possibleCondition   = 'Possible Condition';
  static const String whatToDo            = 'What You Should Do Now';
  static const String riskLevel           = 'Risk Level';
  static const String riskLow             = 'Low';
  static const String riskMedium          = 'Medium';
  static const String riskHigh            = 'High';
  static const String backHome            = 'Back Home';
  static const String diagnoseAgain       = 'Diagnose Again';

  // ── Crops ─────────────────────────────────────────────────────────
  static const String cropsTitle          = 'Crop Recommendation';
  static const String cropsSubtitle       = 'Enter your farm conditions';
  static const String soilType            = 'Soil Type';
  static const String landSize            = 'Land Size (hectares)';
  static const String season              = 'Current Season';
  static const String location            = 'Location / Region';
  static const String getCropAdvice       = 'Get Crop Advice';
  static const String recommendedCrops    = 'Recommended Crops';
  static const String plantingTips        = 'Planting Tips';

  // ── Chat ──────────────────────────────────────────────────────────
  static const String chatTitle           = 'AI Farm Assistant';
  static const String chatHint            = 'Ask me anything about farming...';
  static const String chatWelcome         = 'Hello! I\'m your Smart Farm Assistant. How can I help you today?';
  static const String chatThinking        = 'Thinking...';

  // ── Profile ───────────────────────────────────────────────────────
  static const String profileTitle        = 'My Profile';
  static const String farmName            = 'Farm Name';
  static const String editProfile         = 'Edit Profile';
  static const String appSettings         = 'App Settings';
  static const String notifications       = 'Notifications';
  static const String language            = 'Language';
  static const String aboutApp            = 'About App';
  static const String version             = 'Version 1.0.0';

  // ── Errors & Validation ───────────────────────────────────────────
  static const String fieldRequired       = 'This field is required';
  static const String invalidEmail        = 'Please enter a valid email';
  static const String passwordTooShort    = 'Password must be at least 6 characters';
  static const String passwordMismatch    = 'Passwords do not match';
  static const String selectAnimal        = 'Please select an animal type';
  static const String selectSymptom       = 'Please select at least one symptom';
  static const String loginFailed         = 'Login failed. Check your credentials.';
  static const String networkError        = 'Network error. Please try again.';
  static const String aiError             = 'AI service unavailable. Please try again.';
}
