class API {
  // Base URLs
  static const hostConnect = "http://192.168.1.3/darjoconnect"; // Perbaiki format URL
  static const hostConnectUser = "$hostConnect/user";
  static const hostConnectAdmin = "$hostConnect/admin";
  
  // Endpoints
  // Registration
  static const validateEmail = "$hostConnectUser/validate_email.php";
  static const registration = "$hostConnectUser/registration.php";

  // Login
  static const login = "$hostConnectUser/login.php";

  // History
  // (Tambahkan endpoint history jika diperlukan)
}
