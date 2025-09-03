import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/geominder_apis.dart';
import '../utils/constants.dart';

class CustomPlaceSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final void Function(double lat, double lng)? onLocationSelected;
  final int maxHistoryItems;

  const CustomPlaceSearchField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.onLocationSelected,
    this.maxHistoryItems = 4,
  }) : super(key: key);

  @override
  _CustomPlaceSearchFieldState createState() => _CustomPlaceSearchFieldState();
}

class _CustomPlaceSearchFieldState extends State<CustomPlaceSearchField> {
  List<dynamic> _placeList = [];
  List<String> _searchHistory = [];
  String _sessionToken = '';
  bool _isLoading = false;
  bool _showHistory = false;
  bool _showSuggestions = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSearchHistory();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _showHistory = widget.controller.text.isEmpty;
        _showSuggestions = widget.controller.text.isNotEmpty;
      });
      if (!_showHistory) {
        _getSuggestions(widget.controller.text);
      }
    }
  }

  void _loadSearchHistory() {
    final history = _prefs.getStringList('place_search_history') ?? [];
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _saveToSearchHistory(String place) async {
    _searchHistory.remove(place);
    _searchHistory.insert(0, place);

    if (_searchHistory.length > widget.maxHistoryItems) {
      _searchHistory = _searchHistory.sublist(0, widget.maxHistoryItems);
    }

    await _prefs.setStringList('place_search_history', _searchHistory);
  }

  void _closeAllPanels() {
    setState(() {
      _showHistory = false;
      _showSuggestions = false;
    });
  }

  void _clearSearch() {
    widget.controller.clear();
    setState(() {
      _placeList.clear();
      _showHistory = true;
      _showSuggestions = false;
    });
  }

  void _getSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _placeList.clear();
        _showHistory = true;
        _showSuggestions = false;
      });
      return;
    }

    if (_sessionToken.isEmpty) {
      _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    }

    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=${Constants.googleMap_apiKey}&sessiontoken=$_sessionToken';

    setState(() {
      _isLoading = true;
      _showHistory = false;
      _showSuggestions = true;
    });

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        debugPrint(response.body);
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getPlaceDetails(String placeId, String placeDescription) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request =
        '$baseURL?place_id=$placeId&key=${Constants.googleMap_apiKey}';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var location = data['result']['geometry']['location'];
        double lat = location['lat'];
        double lng = location['lng'];

        await _saveToSearchHistory(placeDescription);

        widget.onLocationSelected?.call(lat, lng);
        debugPrint("Selected Location: Latitude: $lat, Longitude: $lng");

        _closeAllPanels();
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
  }

  void _selectHistoryItem(String historyItem) {
    widget.controller.text = historyItem;
    FocusScope.of(context).unfocus();
    _getSuggestions(historyItem);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
            BoxShadow(
            color: isDark
            ? Colors.black.withOpacity(0.3)
                : Colors.blueGrey.withOpacity(0.2),
        spreadRadius: 12,
        blurRadius: 16,
        offset: Offset(0, 4),
            )
      ],

    ),
    child: TextField(
    controller: widget.controller,
    onChanged: (value) {
    _getSuggestions(value);
    },
    onTap: () {
    setState(() {
    _showHistory = widget.controller.text.isEmpty;
    _showSuggestions = widget.controller.text.isNotEmpty;
    });
    },
    style: TextStyle(
    color: isDark ? Colors.white : Colors.black,
    ),
    decoration: InputDecoration(
    filled: true,
    fillColor: isDark ? Colors.grey[850] : Colors.white,
    hintText: widget.hintText,
    hintStyle: TextStyle(
    color: isDark ? Colors.grey[400] : Colors.grey,
    ),
    labelText: widget.labelText,
    labelStyle: TextStyle(
    color: isDark ? Colors.white70 : kTextBlackColor,
    fontWeight: FontWeight.w600,
    ),
    alignLabelWithHint: true,
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(
    color: isDark ? Colors.grey[700]! : Colors.grey,
    ),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(
    color: kPrimaryColor,
    width: 2.0,
    ),
    ),
    suffixIcon: _isLoading
    ? Padding(
    padding: EdgeInsets.all(10),
    child: CircularProgressIndicator(
    color: kPrimaryColor,
    strokeWidth: 2.5,
    ),
    )
        : widget.controller.text.isNotEmpty
    ? IconButton(
    icon: Icon(Icons.clear,
    color: isDark ? Colors.white70 : Colors.grey),
    onPressed: _clearSearch,
    )
        : null,
    ),
    ),
    ),
    if (_showHistory && _searchHistory.isNotEmpty)
    _buildHistoryList(isDark),
    if (_showSuggestions && _placeList.isNotEmpty)
    _buildSuggestionsList(isDark),
    ],
    );
    }

  Widget _buildHistoryList(bool isDark) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.history,
                    color: isDark ? Colors.grey[400] : Colors.grey),
                title: Text(
                  _searchHistory[index],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () => _selectHistoryItem(_searchHistory[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(bool isDark) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _placeList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.location_on,
                color: isDark ? Colors.grey[400] : Colors.grey),
            title: Text(
              _placeList[index]['description'],
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            onTap: () async {
              String selectedPlace = _placeList[index]['description'];
              String placeId = _placeList[index]['place_id'];

              widget.controller.text = selectedPlace;
              FocusScope.of(context).unfocus();
              await _getPlaceDetails(placeId, selectedPlace);
            },
          );
        },
      ),
    );
  }
}