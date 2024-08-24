import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/posts_cubit.dart';
import '../data/models/post.dart';

typedef LoadMoreCallback = Future<void> Function();

class PaginationScrollController {
  final ScrollController scrollController = ScrollController();
  bool _isFetching = false;
  bool _hasLoadMore = true;
  int listCount = 0;

  void setupScrollController(BuildContext context, LoadMoreCallback loadMoreCallback) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge && scrollController.position.pixels != 0) {
        if (_hasLoadMore) {
          if (!_isFetching) {
            _isFetching = true;
            loadMoreCallback().then((_) => _isFetching = false);
          }
        }
      }
    });
  }

  void checkIfNeedsMoreData(BuildContext context, LoadMoreCallback loadMoreCallback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.position.maxScrollExtent == 0 && !_isFetching) {
        _isFetching = true;
        loadMoreCallback().then((_) => _isFetching = false);
      }
    });
  }

  void updateLoadMoreStatus(int newListCount, int oldListCount) {
    if (newListCount == oldListCount) {
      _hasLoadMore = false;
    } else {
      listCount = newListCount;
    }
  }

  void resetPagination() {
    _isFetching = false;
    _hasLoadMore = true;
    listCount = 0;
  }
}

class PostScreen extends StatelessWidget {
  final PaginationScrollController paginationController = PaginationScrollController();

  PostScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    paginationController.setupScrollController(context, () => _loadMorePosts(context));
    paginationController.checkIfNeedsMoreData(context, () => _loadMorePosts(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _postList(),
      ),
    );
  }

  Future<void> _loadMorePosts(BuildContext context) async {
    BlocProvider.of<PostsCubit>(context).loadPosts();
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
        paginationController.updateLoadMoreStatus(posts.length, paginationController.listCount);
      }

      return ListView.separated(
        controller: paginationController.scrollController,
        itemBuilder: (context, index) {
          if (index < posts.length) {
            return _post(posts[index], context);
          } else {
            Timer(const Duration(milliseconds: 30), () {
              paginationController.scrollController.jumpTo(paginationController.scrollController.position.maxScrollExtent);
            });
            return _loadingIndicator();
          }
        },
        separatorBuilder: (context, index) => Divider(color: Colors.grey[400]),
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
            style: const TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
