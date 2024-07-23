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
  final String apiKey = 'AIzaSyB-xnND_MGHozbAkRMRoZ4PVq6CXde_cC0';

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
      body: SingleChildScrollView(
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
            SizedBox(height: 16.0),
            if (placeDetails!['rating'] != null)
              Row(
                children: [
                  Text(
                    'Average Rating: ${placeDetails!['rating']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8.0),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < placeDetails!['rating']
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            if (placeDetails!['reviews'] != null) ...[
              Text(
                'Reviews:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildReviewsList(placeDetails!['reviews']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(List reviews) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ListTile(
          title: Text(review['author_name'] ?? 'Anonymous'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
              Text(review['text'] ?? 'No review text'),
            ],
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(review['profile_photo_url'] ??
                'https://via.placeholder.com/50'),
          ),
        );
      },
    );
  }
}
