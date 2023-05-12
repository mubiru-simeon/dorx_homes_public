import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'dart:convert' as convert;

import '../constants/constants.dart';

class LocationService {
  Future<void> openInGoogleMaps(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    await StorageServices().launchTheThing(googleUrl);
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    await  StorageServices().launchTheThing(googleUrl);
  }

  Future<Map<String, dynamic>> getAddressFromLatLng(
    LatLng currentPosition,
  ) async {
    String textToReturn;
    Map<String, dynamic> ret = {};

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      Placemark place = placemarks[0];
      textToReturn =
          "${place.locality}, ${place.postalCode}, ${place.country}, ${place.street}";

      ret.addAll({
        "text": textToReturn,
        "pla": place,
      });
    } catch (e) {
      textToReturn = null;

      ret = null;
    }

    return ret;
  }

  Future<dynamic> getUserLocation(
    BuildContext context,
  ) async {
    return await _determinePosition().then((value) async {
      if (value.entries.first.key ==
          LocationFeedback.locationPermissionGranted) {
        return LatLng(
          value.entries.first.value["location"].latitude,
          value.entries.first.value["location"].longitude,
        );
      } else {
        return {
          value.entries.first.key: value.entries.first.value,
        };
      }
    });
  }

  Future<Map<LocationFeedback, Map<String, dynamic>>>
      _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        LocationFeedback.locationIsOff: {
          "message":
              'Location services are disabled. Please click here and turn on your location and try again'
        }
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return {
        LocationFeedback.locationPermissionDeniedForever: {
          "message":
              'Location permissions are permantly denied, we cannot find your current location. Please tap the button below, then Permissions and then grant location permissions.\n\nIf You completely fail, feel free to check FAQs for assistance'
        }
      };
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return {
          LocationFeedback.locationPermissionDenied: {
            "message":
                'Location permissions have been denied. Please grant the needed permissions in order to proceed.'
          }
        };
      }
    }

    return await Geolocator.getCurrentPosition().then((value) {
      return {
        LocationFeedback.locationPermissionGranted: {
          "message": 'Success',
          "location": value,
        }
      };
    });
  }
}

enum LocationFeedback {
  locationIsOff,
  locationPermissionDeniedForever,
  locationPermissionDenied,
  locationPermissionGranted,
}

class PlaceSearch {
  final String description;
  final String placeId;

  PlaceSearch({this.description, this.placeId});

  factory PlaceSearch.fromJson(Map<String, dynamic> json) {
    return PlaceSearch(
        description: json['description'], placeId: json['place_id']);
  }
}

class PlacesService {
  final key = googleMapsKey;

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }

  Future<List<Place>> getPlaces(
      double lat, double lng, String placeType) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?location=$lat,$lng&type=$placeType&rankby=distance&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }
}

class Place {
  final Geometry geometry;
  final String name;
  final String vicinity;

  Place({this.geometry, this.name, this.vicinity});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      geometry: Geometry.fromJson(json['geometry']),
      name: json['formatted_address'],
      vicinity: json['vicinity'],
    );
  }
}

class Geometry {
  final Location location;

  Geometry({this.location});

  Geometry.fromJson(Map<dynamic, dynamic> parsedJson)
      : location = Location.fromJson(parsedJson['location']);
}

class Location {
  final double lat;
  final double lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Location(lat: parsedJson['lat'], lng: parsedJson['lng']);
  }
}
