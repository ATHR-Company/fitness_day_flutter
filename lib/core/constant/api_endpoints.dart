class ApiEndpoints {
  static const String baseUrl = 'https://fitnessday.tech/api';
  
  static const String userSignup = '/auth/user/signup';
  static const String userVerifyOtp = '/auth/user/verify-otp';
  static const String userLookups = '/lookups/user';
  static const String healthQuestions = '/health-questions';
  static const String completePersonalData = '/users/complete-personal-data';
  static const String submitHealthAnswers = '/users/submit-health-answers';
  static const String authRefresh = '/auth/refresh';
  static const String socialAuth = '/auth/social';
}
