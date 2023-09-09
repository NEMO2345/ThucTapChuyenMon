/// OPENROUTESERVICE DIRECTION SERVICE REQUEST
/// Parameters are : startPoint, endPoint and api key

const String baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';
const String apiKey = '5b3ce3597851110001cf6248e3d915e0ad3a466dbdb75068a05aa2b3';
const String infoLocationUrl = 'https://nominatim.openstreetmap.org/reverse';

getRouteUrl(String startPoint, String endPoint){
  return Uri.parse('$baseUrl?api_key=$apiKey&start=$startPoint&end=$endPoint');
}

getinfoLocationUrl(String lat, String lon){
  return Uri.parse('$infoLocationUrl?lat=$lat&lon=$lon&format=json');
}