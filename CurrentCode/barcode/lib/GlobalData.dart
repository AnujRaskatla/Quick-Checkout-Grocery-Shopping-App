// ignore_for_file: file_names

class GlobalData {
  static String? cartNumber = '';
  static String? userName;
  static String? userEmail;
  static double weight = 0.0;
  static double totalPriceInPaise = 0.0;
  static double InitialPrice = 0.0;
  static void setUserProfile(String? name, String? email) {
    userName = name;
    userEmail = email;
  }
}
