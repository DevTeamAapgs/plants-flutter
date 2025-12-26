class URLs {
  static const String baseUrl =
      'https://oragadam-mdp-api.herbalgarden.in/api/'; /* PROD */
  static const String imageUrl =
      'https://oragadam-mdp-api.herbalgarden.in'; /* PROD */
  // static const String baseUrl = 'http://plantsapi.thedevdemo.in/api/'; /* UAT */
  // static const String imageUrl = 'http://plantsapi.thedevdemo.in'; /* UAT */
  // static const String baseUrl = 'http://192.168.1.104:3000/api/'; /* local */
  // static const String imageUrl = 'http://192.168.1.104:3000/'; /* local */
  static const String getPlantsList = '${baseUrl}plants';
  static const String getGallery = '${baseUrl}gallery';
  static const String getSectorList = '${baseUrl}sector';
  static const String postFeedback = '${baseUrl}feedback';
  static const String dashboard = '${baseUrl}dashboard';
  static const String syncPlants = '${baseUrl}dashboard/sync';
  static const String apiHealth = '$imageUrl/health';
}
