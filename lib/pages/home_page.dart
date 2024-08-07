import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:travel_buddy/pages/place_details.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String?>> restaurants = [];

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces([String query = '']) async {
    const apiKey =
        'AIzaSyB-xnND_MGHozbAkRMRoZ4PVq6CXde_cC0'; // Replace with your actual API key
    const location = '40.7128,-74.0060'; // New York City location
    const radius = '1000'; // Example radius in meters

    String url;
    if (query.isEmpty) {
      url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=$radius&type=restaurant&key=$apiKey';
    } else {
      url =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=$location&radius=$radius&type=restaurant&key=$apiKey';
    }

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      // Debugging: print the full response
      if (kDebugMode) {
        print('API Response: $data');
      }

      final results = data['results'];

      setState(() {
        restaurants = [];
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

          // Debugging: print the type of each place
          if (kDebugMode) {
            print('Place: $name, Types: $types');
          }

          if (types != null && types.contains('restaurant')) {
            restaurants
                .add({'name': name, 'photoUrl': photoUrl, 'placeId': placeId});
          }
        }

        // Debugging: print the list of restaurants
        if (kDebugMode) {
          print('Restaurants: $restaurants');
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching places: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('lib/images/profile.png'),
                    radius: 30,
                  ),
                  const SizedBox(width: 16.0),
                  Text('Welcome, ${widget.username}'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification clicked!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Nearby Restaurants Section
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Nearby Restaurants:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildPlacesList(restaurants),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () async {
                fetchPlaces();
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
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
              icon: const Icon(Icons.logout),
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
          leading: place['photoUrl'] != null
              ? Image.network(place['photoUrl']!,
                  width: 50, height: 50, fit: BoxFit.cover)
              : null,
          title: Text(place['name'] ?? 'No name'),
          subtitle: place['rating'] != null
              ? Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text('${place['rating']}')
                  ],
                )
              : null,
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
    const apiKey =
        'AIzaSyB-xnND_MGHozbAkRMRoZ4PVq6CXde_cC0'; // Replace with your actual API key
    const location = '40.7128,-74.0060'; // New York City location
    const radius = '1000'; // Example radius in meters

    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=$location&radius=$radius&type=restaurant&key=$apiKey';

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
          'types': types.join(', '),
          'rating': result['rating']?.toString() ?? 'No rating'
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching suggestions: $error');
      }
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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
    return const Center(
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
          subtitle: suggestion['rating'] != null
              ? Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text('${suggestion['rating']}')
                  ],
                )
              : null,
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
