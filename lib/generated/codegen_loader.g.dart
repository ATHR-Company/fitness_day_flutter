// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _ar = {
  "login": {
    "welcome_text": "سعداء بعودتك من جديد سجّل الدخول لمتابعة رحلتك نحو نسختك الأقوى",
    "phone_hint": "رقم الجوال",
    "password_hint": "كلمة المرور",
    "password_error": "الرجاء إدخال كلمة المرور",
    "forgot_password": "نسيت كلمة المرور؟",
    "login_button": "تسجيل الدخول",
    "next_button": "التالي",
    "success_login": "تم تسجيل الدخول بنجاح",
    "search_country_hint": "ابحث عن الدولة أو الرمز",
    "phone_local_digits_min": "رقم الجوال يجب أن يكون على الأقل {} أرقام"
  },
  "visits": {
    "title": "سجل الزيارات",
    "search_hint": "بحث عن عميل أو زيارة",
    "tab_upcoming": "القادمة",
    "tab_history": "السجل",
    "in_minutes": "بعد {} دقيقة",
    "client_name_label": "اسم العميل :",
    "visit_time_label": "ميعاد الزيارة :",
    "visit_location_label": "مكان الزيارة :",
    "view_visit": "عرض الزيارة »",
    "today": "اليوم",
    "pm": "مساءاً",
    "hq_location": "في مقر يوم الرشاقة",
    "dummy_title": "متابعة أسبوعية",
    "dummy_subtitle": "متابعة الوزن وتخصيص النظام الغذائي والرياضي له",
    "dummy_client": "محمد عبدالله"
  },
  "visit_details": {
    "title": "تفاصيل الزيارة",
    "tab_visit_data": "بيانات الزيارة",
    "tab_custom_plan": "النظام المخصص",
    "tab_report": "التقرير",
    "visit_goal_title": "الهدف من الزيارة",
    "goal_1": "تعديل السعرات اليومية لتناسب هدفك",
    "goal_2": "تحديث خطة التمارين",
    "goal_3": "ضبط توزيع البروتين والكربوهيدرات",
    "goal_4": "متابعة تقدمك خلال الأسبوع الماضي",
    "start_visit": "بدء الزيارة",
    "reschedule": "إعادة جدولة",
    "reschedule_title": "طلب تغيير ميعاد الزيارة",
    "save": "حفظ",
    "cancel": "إلغاء"
  }
};
static const Map<String,dynamic> _en = {
  "login": {
    "welcome_text": "Happy to see you again. Log in to continue\nyour journey towards your strongest version",
    "phone_hint": "Phone Number",
    "password_hint": "Password",
    "password_error": "Please enter password",
    "forgot_password": "Forgot Password?",
    "login_button": "Login",
    "next_button": "Next",
    "success_login": "Logged in successfully",
    "search_country_hint": "Search for country or code",
    "phone_local_digits_min": "Phone number must be at least {} digits"
  },
  "visits": {
    "title": "Visits Log",
    "search_hint": "Search for client or visit",
    "tab_upcoming": "Upcoming",
    "tab_history": "History",
    "in_minutes": "In {} minutes",
    "client_name_label": "Client Name :",
    "visit_time_label": "Visit Time :",
    "visit_location_label": "Location :",
    "view_visit": "View Visit »",
    "today": "Today",
    "pm": "PM",
    "hq_location": "Fitness Day HQ",
    "dummy_title": "Weekly Follow-up",
    "dummy_subtitle": "Weight follow-up and customizing diet and sports regimen",
    "dummy_client": "Mohamed Abdullah"
  },
  "visit_details": {
    "title": "Visit Details",
    "tab_visit_data": "Visit Data",
    "tab_custom_plan": "Custom Plan",
    "tab_report": "Report",
    "visit_goal_title": "Visit Goal",
    "goal_1": "Adjust daily calories to match your goal",
    "goal_2": "Update exercise plan",
    "goal_3": "Balance protein and carbohydrate distribution",
    "goal_4": "Follow up on progress from last week",
    "start_visit": "Start Visit",
    "reschedule": "Reschedule",
    "reschedule_title": "Reschedule Visit Request",
    "save": "Save",
    "cancel": "Cancel"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ar": _ar, "en": _en};
}
