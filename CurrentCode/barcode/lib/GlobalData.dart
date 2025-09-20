// ignore_for_file: file_names

class GlobalData {
  static String? cartNumber = '';
  static String? userName;

  static String? userEmail;

  static void setUserProfile(String? name, String? email) {
    userName = name;
    userEmail = email;
  }
}
