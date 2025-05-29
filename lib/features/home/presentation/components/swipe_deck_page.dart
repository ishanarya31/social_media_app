import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:social_media_app/features/home/presentation/components/post_tile.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_state.dart';
import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/pages/upload_post_page.dart';
import '../components/my_drawer.dart';

class SwipeDeckPage extends StatefulWidget {
  const SwipeDeckPage({Key? key}) : super(key: key);

  @override
  State<SwipeDeckPage> createState() => _SwipeDeckPageState();
}

class _SwipeDeckPageState extends State<SwipeDeckPage> {
  late final PostCubit postCubit;
  late CardSwiperController controller;

  // Track which posts have been seen to enable infinite loop
  List<String> seenPostIds = [];
  int currentLoopIteration = 0;

  @override
  void initState() {
    super.initState();
    postCubit = context.read<PostCubit>();
    controller = CardSwiperController();

    // Fetch all posts on startup
    fetchAllPosts();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    // Remove from seen posts if it was there
    seenPostIds.remove(postId);
    fetchAllPosts();
  }

  // Create an infinite looping list of posts
  List<Post> createInfinitePostList(List<Post> originalPosts) {
    if (originalPosts.isEmpty) return [];

    // Create multiple copies for infinite scrolling
    List<Post> infinitePosts = [];
    for (int i = 0; i < 10; i++) { // 10 loops should be enough
      infinitePosts.addAll(originalPosts);
    }
    return infinitePosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swipe Posts"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadPostPage()),
            ),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchAllPosts();
              setState(() {
                seenPostIds.clear();
                currentLoopIteration = 0;
                controller = CardSwiperController();
              });
            },
          ),
        ],
      ),

      // Menu drawer - same as HomePage
      drawer: const MyDrawer(),

      // Body with BlocBuilder like HomePage
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // Loading state
          if (state is PostsLoading || state is PostsUploading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Loaded state
          else if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No Posts to display x/",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Create infinite post list for looping
            final infinitePosts = createInfinitePostList(allPosts);
            final totalOriginalPosts = allPosts.length;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(double.minPositive),
                child: Column(
                  children: [
                    // Progress indicator showing current position in original posts
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    // Card swiper
                    Expanded(
                      child: CardSwiper(
                        controller: controller,
                        cardsCount: infinitePosts.length,
                        cardBuilder: (context, index, horizontalThreshold, verticalThreshold) {
                          if (index >= infinitePosts.length) {
                            return const SizedBox.shrink();
                          }

                          final post = infinitePosts[index];

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PostTile(
                                post: post,
                                onDeletePressed: () => deletePost(post.id),
                              ),
                            ),
                          );
                        },
                        numberOfCardsDisplayed: 3,
                        backCardOffset: const Offset(0, -40),
                        padding: const EdgeInsets.all(8.0),
                        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                          horizontal: true,
                          vertical: true,
                        ),
                        threshold: 50,
                        maxAngle: 30,
                        isLoop: true, // Enable infinite loop
                        onSwipe: (previousIndex, currentIndex, direction) =>
                            _onSwipe(previousIndex, currentIndex, direction, infinitePosts, totalOriginalPosts),
                        onEnd: () => _onEnd(allPosts),
                        onUndo: _onUndo,
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          // Undo button
                          FloatingActionButton(
                            heroTag: "undo",
                            onPressed: () => controller.undo(),
                            backgroundColor: Colors.grey.shade600,
                            elevation: 2,
                            child: const Icon(Icons.undo, color: Colors.white),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Error state
          else if (state is PostsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchAllPosts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  bool _onSwipe(
      int previousIndex,
      int? currentIndex,
      CardSwiperDirection direction,
      List<Post> infinitePosts,
      int totalOriginalPosts,
      ) {
    if (previousIndex >= infinitePosts.length) return false;

    final post = infinitePosts[previousIndex];

    // Track seen posts and loop iteration
    if (!seenPostIds.contains(post.id)) {
      seenPostIds.add(post.id);
    }

    // Update loop iteration when we complete a full cycle
    final currentPosition = seenPostIds.length % totalOriginalPosts;
    if (currentPosition == 0 && seenPostIds.length > 0) {
      setState(() {
        currentLoopIteration = seenPostIds.length ~/ totalOriginalPosts;
      });
    } else {
      setState(() {}); // Update UI for progress indicator
    }

    debugPrint('Swiped ${direction.name} on post: ${post.id}');
    debugPrint('Loop ${currentLoopIteration + 1}, Position: ${currentPosition + 1}/$totalOriginalPosts');

    // Handle different swipe directions
    return true; // Allow the swipe
  }

  void _onEnd(List<Post> allPosts) {
    // This should rarely be called since we have infinite loop enabled
    debugPrint('Reached end of infinite posts - refreshing');
    fetchAllPosts();
  }

  bool _onUndo(
      int? previousIndex,
      int currentIndex,
      CardSwiperDirection direction,
      ) {
    debugPrint('Undid ${direction.name} on post at index $currentIndex');

    // Update seen posts tracking on undo
    if (seenPostIds.isNotEmpty) {
      seenPostIds.removeLast();
      setState(() {}); // Update progress indicator
    }

    return true; // Allow the undo
  }
}