import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pagination_with_bloc/presentation/posts_view.dart';
import 'package:flutter_pagination_with_bloc/presentation/posts_screen.dart';

import 'cubit/posts_cubit.dart';
import 'data/repositories/posts_respository.dart';
import 'data/services/posts_service.dart';

void main() {
  runApp(MyApp(repository: PostsRepository(PostsService()),));
}

class MyApp extends StatelessWidget {
  final PostsRepository repository;

  const MyApp({super.key,required this.repository});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Pagination',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => PostsCubit(repository),
        child: PostScreen(),
      ),
    );
  }
}
