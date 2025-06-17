import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';

import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/search_response.dart';


class MoviesProvider extends ChangeNotifier {


  final String _baseURL='api.themoviedb.org';
  final String _token='eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MDkwNTAyMjEwNzFhNjcxZGIwYzlmZGYwYjU4NWE4OSIsIm5iZiI6MTc0OTc2NTE5OC4zNTUsInN1YiI6IjY4NGI0YzRlZDI0ODM5ZTg0ZTNmZGE3MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.MstQU8h94CtEvDS5LXbeyXkm0wNQYJnwCozxw5VoNwE';
  final String _language='es-MX';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionStreamController = new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionStreamController.stream;

  MoviesProvider() {
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page=1]) async {
    var url = Uri.https(_baseURL, endpoint, {
      'language': _language,
      'page': '$page'
    });

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json;charset=utf-8',
      'Authorization': 'Bearer $_token',
      }
    );

    return response.body;
  }


  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');

    final nowPlayingRespone = NowPlayingResponse.fromJson(jsonData);

    this.onDisplayMovies = nowPlayingRespone.results;

    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('3/movie/popular',_popularPage);

    final popularResponse = PopularResponse.fromJson(jsonData);

    this.popularMovies = [...popularMovies, ...popularResponse.results];

    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');

    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    var url = Uri.https(_baseURL, '3/search/movie', {
      'language': _language,
      'query': query,
    });

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json;charset=utf-8',
        'Authorization': 'Bearer $_token',
      },
    );

    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await this.searchMovies(value);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
  
}
