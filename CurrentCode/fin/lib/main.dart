import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CSV Search',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 20),
            SearchForm(),
          ],
        ),
      ),
    );
  }
}

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  SearchFormState createState() => SearchFormState();
}

class SearchFormState extends State<SearchForm> {
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch() {
    String searchTerm = _searchController.text;

    if (searchTerm.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultPage(searchTerm: searchTerm),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter a number',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _handleSearch,
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

class SearchResultPage extends StatefulWidget {
  final String searchTerm;

  const SearchResultPage({super.key, required this.searchTerm});

  @override
  SearchResultPageState createState() => SearchResultPageState();
}

class SearchResultPageState extends State<SearchResultPage> {
  late List<List<dynamic>> csvData;
  late List<List<dynamic>> searchResults;

  @override
  void initState() {
    super.initState();
    _loadCSVData();
  }

  Future<void> _loadCSVData() async {
    final String csvString = await rootBundle.loadString('assets/data.csv');
    csvData = const CsvToListConverter().convert(csvString);

    // Convert the search term to a string for comparison
    String searchTerm = widget.searchTerm;

    searchResults = csvData
        .where((row) => row[0].toString() == searchTerm)
        .toList(growable: false);

    if (searchResults.isNotEmpty) {
      // Display the result from the adjacent column (index 1)
      searchResults = searchResults.map((row) => [searchTerm, row[1]]).toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Result'),
      ),
      body: Center(
        child: searchResults.isEmpty
            ? const Text('No results found')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Search Term: ${widget.searchTerm}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Column 1: ${searchResults[index][0]}'),
                        subtitle: Text('Column 2: ${searchResults[index][1]}'),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
