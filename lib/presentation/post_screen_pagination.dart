import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/posts_cubit.dart';
import '../data/models/post.dart';

class PostScreenPagination extends StatelessWidget {
  final scrollController = ScrollController();
  bool _isFetching = false;
  int listCount = 0;
  bool _hasLoadMore = true;

  PostScreenPagination({super.key});

  void setupScrollController(context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge && scrollController.position.pixels != 0) {
        if(_hasLoadMore){
          if (!_isFetching) {
            _isFetching = true;
            BlocProvider.of<PostsCubit>(context).loadPosts();
          }
        }
      }
    });
  }

  void checkIfNeedsMoreData(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.position.maxScrollExtent == 0 && !_isFetching) {
        _isFetching = true;
        BlocProvider.of<PostsCubit>(context).loadPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setupScrollController(context);
    checkIfNeedsMoreData(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: _postList(),
    );
  }

  Widget _postList() {
    return BlocBuilder<PostsCubit, PostsState>(builder: (context, state) {
      if (state is PostsLoading && state.isFirstFetch) {
        return _loadingIndicator();
      }

      List<Post> posts = [];
      bool isLoading = false;

      if (state is PostsLoading) {
        posts = state.oldPosts;
        isLoading = true;
      } else if (state is PostsLoaded) {
        posts = state.posts;
        _isFetching = false;
        debugPrint("${state.posts.length}");
        debugPrint("${posts.length}");
        if(listCount== posts.length){
          _hasLoadMore = false;
        } else {
          listCount = posts.length;
        }
        if(state.posts.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data list is empty'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.blue,
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.position.maxScrollExtent == 0 && !_isFetching) {
            _isFetching = true;
            BlocProvider.of<PostsCubit>(context).loadPosts();
          }
        });
      }

      return ListView.separated(
        controller: scrollController,
        itemBuilder: (context, index) {
          if (index < posts.length) {
            return _post(posts[index], context);
          } else {
            Timer(const Duration(milliseconds: 30), () {
              scrollController.jumpTo(scrollController.position.maxScrollExtent);
            });
            return _loadingIndicator();
          }
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey[400],
          );
        },
        itemCount: posts.length + (isLoading ? 1 : 0),
      );
    });
  }

  Widget _loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _post(Post post, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${post.id}. ${post.title}",
            style: const TextStyle(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          //Text(post.body)
        ],
      ),
    );
  }
}