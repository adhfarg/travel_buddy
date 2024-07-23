import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:travel_buddy/pages/place_details.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String?>> restaurants = [];
  List<Map<String, String?>> hotels = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces([String query = '']) async {
    final apiKey =
        'AIzaSyB-xnND_MGHozbAkRMRoZ4PVq6CXde_cC0'; // Replace with your actual API key
    final location = '40.7128,-74.0060'; // New York City location
    final radius = '1000'; // Example radius in meters

    String url;
    if (query.isEmpty) {
      url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=$radius&type=restaurant|lodging&key=$apiKey';
    } else {
      url =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=$location&radius=$radius&key=$apiKey';
    }

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      final results = data['results'];

      setState(() {
        restaurants = [];
        hotels = [];
        for (var result in results) {
          final name = result['name'];
          final placeId = result['place_id'];
          final types = result['types'];
          final photoReference = result['photos'] != null
              ? result['photos'][0]['photo_reference']
              : null;
          final photoUrl = photoReference != null
              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey'
              : null;

          if (types != null && types.contains('restaurant')) {
            restaurants
                .add({'name': name, 'photoUrl': photoUrl, 'placeId': placeId});
          } else if (types != null && types.contains('lodging')) {
            hotels
                .add({'name': name, 'photoUrl': photoUrl, 'placeId': placeId});
          }
        }
      });
    } catch (error) {
      print('Error fetching places: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: CustomSearchDelegate(fetchPlaces: fetchPlaces),
              );
              if (result != null) {
                fetchPlaces(result);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('lib/images/profile.png'),
                    radius: 30,
                  ),
                  SizedBox(width: 16.0),
                  Text('Welcome, ${widget.username}'),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Nearby Restaurants Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Nearby Restaurants:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildPlacesList(restaurants),
            // Nearby Hotels Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Nearby Hotels:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildPlacesList(hotels),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () async {
                fetchPlaces();
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                final result = await showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(fetchPlaces: fetchPlaces),
                );
                if (result != null) {
                  fetchPlaces(result);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList(List<Map<String, String?>> places) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
          leading: place['photoUrl'] != null
              ? Image.network(place['photoUrl']!,
                  width: 50, height: 50, fit: BoxFit.cover)
              : null,
          title: Text(place['name'] ?? 'No name'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetails(placeId: place['placeId']!),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final Function fetchPlaces;

  CustomSearchDelegate({required this.fetchPlaces});

  List<Map<String, String?>> _suggestions = [];

  Future<void> _fetchSuggestions(String query) async {
    final apiKey =
        'AIzaSyB-xnND_MGHozbAkRMRoZ4PVq6CXde_cC0'; // Replace with your actual API key
    final location = '40.7128,-74.0060'; // New York City location
    final radius = '1000'; // Example radius in meters

    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=$location&radius=$radius&type=restaurant|lodging&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      final results = data['results'];

      _suggestions = [];
      for (var result in results) {
        final name = result['name'];
        final placeId = result['place_id'];
        final types = result['types'];
        final photoReference = result['photos'] != null
            ? result['photos'][0]['photo_reference']
            : null;
        final photoUrl = photoReference != null
            ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey'
            : null;

        _suggestions.add({
          'name': name,
          'photoUrl': photoUrl,
          'placeId': placeId,
          'types': types.join(', ')
        });
      }
    } catch (error) {
      print('Error fetching suggestions: $error');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPlaces(query);
    });
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }

    _fetchSuggestions(query);

    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return ListTile(
          leading: suggestion['photoUrl'] != null
              ? Image.network(suggestion['photoUrl']!,
                  width: 50, height: 50, fit: BoxFit.cover)
              : null,
          title: Text(suggestion['name'] ?? 'No name'),
          subtitle: Text(suggestion['types'] ?? 'No type'),
          onTap: () {
            close(context, suggestion['name']);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              fetchPlaces(suggestion['name']!);
            });
          },
        );
      },
    );
  }
}
