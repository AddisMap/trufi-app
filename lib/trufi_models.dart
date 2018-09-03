import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_app/trufi_localizations.dart';

class TrufiLocation {
  static const String _Description = 'description';
  static const String _Latitude = 'latitude';
  static const String _Longitude = 'longitude';

  final String description;
  final double latitude;
  final double longitude;

  TrufiLocation({this.description, this.latitude, this.longitude});

  factory TrufiLocation.fromLatLng(String description, LatLng point) {
    return TrufiLocation(
      description: description,
      latitude: point.latitude,
      longitude: point.longitude,
    );
  }

  factory TrufiLocation.fromSearchJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'],
      latitude: json['lat'],
      longitude: json['lng'],
    );
  }

  factory TrufiLocation.fromImportantPlacesJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['name'],
      latitude: json['coords']['lat'],
      longitude: json['coords']['lng'],
    );
  }

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json[_Description],
      latitude: json[_Latitude],
      longitude: json[_Longitude],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      _Description: description,
      _Latitude: latitude,
      _Longitude: longitude,
    };
  }

  bool operator ==(o) =>
      o is TrufiLocation &&
      o.description == description &&
      o.latitude == latitude &&
      o.longitude == longitude;

  int get hashCode =>
      description.hashCode ^ latitude.hashCode ^ longitude.hashCode;

  String toString() {
    return '$latitude,$longitude';
  }
}

class Plan {
  final int date;
  final PlanLocation from;
  final PlanLocation to;
  final List<PlanItinerary> itineraries;
  final PlanError error;

  Plan({this.date, this.from, this.to, this.itineraries, this.error});

  factory Plan.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      return Plan(error: PlanError.fromJson(json['error']));
    } else {
      Map<String, dynamic> planJson = json['plan'];
      return Plan(
          date: planJson['date'],
          from: PlanLocation.fromJson(planJson['from']),
          to: PlanLocation.fromJson(planJson['to']),
          itineraries: planJson['itineraries']
              .map<PlanItinerary>(
                  (itineraryJson) => new PlanItinerary.fromJson(itineraryJson))
              .toList());
    }
  }

  factory Plan.fromError(String error) {
    return Plan(error: PlanError.fromError(error));
  }
}

class PlanError {
  final int id;
  final String message;

  PlanError(this.id, this.message);

  factory PlanError.fromJson(Map<String, dynamic> json) {
    return PlanError(json['id'], json['msg']);
  }

  factory PlanError.fromError(String error) {
    return PlanError(-1, error);
  }
}

class PlanLocation {
  final String name;
  final double latitude;
  final double longitude;

  PlanLocation({this.name, this.latitude, this.longitude});

  factory PlanLocation.fromJson(Map<String, dynamic> json) {
    return PlanLocation(
        name: json['name'], latitude: json['lat'], longitude: json['lon']);
  }
}

class PlanItinerary {
  final int duration;
  final int startTime;
  final int endTime;
  final int walkTime;
  final int transitTime;
  final int waitingTime;
  final double walkDistance;
  final bool walkLimitExceeded;
  final double elevationLost;
  final double elevationGained;
  final int transfers;
  final List<PlanItineraryLeg> legs;

  PlanItinerary(
      {this.duration,
      this.startTime,
      this.endTime,
      this.walkTime,
      this.transitTime,
      this.waitingTime,
      this.walkDistance,
      this.walkLimitExceeded,
      this.elevationLost,
      this.elevationGained,
      this.transfers,
      this.legs});

  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return new PlanItinerary(
        duration: json['duration'],
        startTime: json['startTime'],
        endTime: json['endTime'],
        walkTime: json['walkTime'],
        transitTime: json['transitTime'],
        waitingTime: json['waitingTime'],
        walkDistance: json['walkDistance'],
        walkLimitExceeded: json['walkLimitExceeded'],
        elevationLost: json['elevationLost'],
        elevationGained: json['elevationGained'],
        transfers: json['transfers'],
        legs: json['legs']
            .map<PlanItineraryLeg>(
                (json) => new PlanItineraryLeg.fromJson(json))
            .toList());
  }
}

class PlanItineraryLeg {
  final String points;
  final String mode;
  final String route;
  final double distance;
  final double duration;
  final String toName;

  PlanItineraryLeg(
      {this.points,
      this.mode,
      this.route,
      this.distance,
      this.duration,
      this.toName});

  factory PlanItineraryLeg.fromJson(Map<String, dynamic> json) {
    return new PlanItineraryLeg(
      points: json['legGeometry']['points'],
      mode: json['mode'],
      route: json['route'],
      distance: json['distance'],
      duration: json['duration'],
      toName: json['to']['name'],
    );
  }

  String toInstruction(BuildContext context) {
    String walk = TrufiLocalizations.of(context).instructionWalk;
    String bus = TrufiLocalizations.of(context).instructionBus;
    String forString = TrufiLocalizations.of(context).instructionFor;
    String toString = TrufiLocalizations.of(context).instructionTo;

    StringBuffer sb = StringBuffer();
    String distanceString = distance >= 1000
        ? (distance.ceil() ~/ 1000).toString() + " km"
        : distance.ceil().toString() + " m";
    String durationString = (duration.ceil() ~/ 60).toString() + " min";
    String destinationString = toName;
    if (mode == 'WALK') {
      if (toName == 'Destination') {
        destinationString = TrufiLocalizations.of(context).commonDestination;
      }
      sb.write(walk +
          " $distanceString " +
          toString +
          " $destinationString ($durationString)");
    } else if (mode == 'BUS') {
      sb.write(bus +
          " $route " +
          forString +
          " $distanceString " +
          toString +
          " $toName ($durationString)");
    }
    return sb.toString();
  }
}
