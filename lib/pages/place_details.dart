import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceDetails extends StatefulWidget {
  final String placeId;

  const PlaceDetails({super.key, required this.placeId});

  @override
  _PlaceDetailsState createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  Map<String, dynamic>? placeDetails;
  final String apiKey =
      'AIzaSyB-xnND_MGHozbAkRMRoZ4PVq6CXde_cC0'; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
    fetchPlaceDetails();
  }

  Future<void> fetchPlaceDetails() async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.placeId}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      setState(() {
        placeDetails = data['result'];
      });
    } catch (error) {
      print('Error fetching place details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (placeDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Place Details'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(placeDetails!['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (placeDetails!['photos'] != null)
              Image.network(
                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeDetails!['photos'][0]['photo_reference']}&key=$apiKey',
              ),
            SizedBox(height: 16.0),
            Text(
              placeDetails!['name'] ?? 'No name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(placeDetails!['formatted_address'] ?? 'No address'),
            SizedBox(height: 8.0),
            if (placeDetails!['formatted_phone_number'] != null)
              Text('Phone: ${placeDetails!['formatted_phone_number']}'),
            if (placeDetails!['opening_hours'] != null)
              ...placeDetails!['opening_hours']['weekday_text']
                  .map<Widget>((day) => Text(day))
                  .toList(),
          ],
        ),
      ),
    );
  }
}
