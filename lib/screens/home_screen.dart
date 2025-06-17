import 'package:flutter/material.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/search/search_delegate.dart';
import 'package:peliculas/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final moviesProvider = Provider.of<MoviesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliculas en Cines'),
        elevation: 10,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            onPressed: () =>showSearch(
              context: context, 
              delegate: MovieSearchDelegate()
            ), 
            icon: Icon(Icons.search_outlined)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
        
            CardSwiper(movies:moviesProvider.onDisplayMovies),
        
            MovieSlider(
              title: 'Populares',
              movies: moviesProvider.popularMovies,
              onNextPage: (){
                moviesProvider.getPopularMovies();
              },
            ),
          ],
        ),
      )
    );
  }
}