import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../post/domain/entities/post.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<StatefulWidget> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  //current user
  AppUser? currentUser;

  //post user
  ProfileUser? postUser;

  //on startup
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  //delete dialog box
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Post',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onDeletePressed?.call();
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: double.minPositive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Profile picture placeholder
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (postUser?.profileImageUrl != null &&
                      postUser!.profileImageUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(postUser!.profileImageUrl)
                      : null,
                  child: (postUser?.profileImageUrl == null ||
                      postUser!.profileImageUrl.isEmpty)
                      ? Text(
                    (postUser?.name ?? widget.post.userName)
                        .trim()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )
                      : null,
                ),

                const SizedBox(width: 12),

                // Username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postUser?.name ?? widget.post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${widget.post.userName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Options menu (only show for own posts)
                if (isOwnPost)
                  IconButton(
                    onPressed: showOptions,
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                    ),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
              ],
            ),
          ),

          // Post content/caption (if exists)

          // Post image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              width: double.infinity,
              height: 420,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 350,
                color: Colors.grey[100],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.grey[100],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),


          // Action buttons (like, comment, share)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: double.minPositive),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Implement like functionality
                  },
                  icon: const Icon(Icons.favorite_border),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    // TODO: Implement comment functionality
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                  icon: const Icon(Icons.share_outlined),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                  ),
                ),


              ],
            ),
          ),


          if (widget.post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.post.text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}