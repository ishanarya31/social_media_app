import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/domain/entities/post.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_state.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  //mobile image pick
  PlatformFile? imagePickedFile;

  //text controller for caption
  final textController = TextEditingController();

  //current user
  AppUser? currentUser;

  @override
  void initState(){
    super.initState();

    getCurrentUser();
  }

  //get current user
  void getCurrentUser() async{
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  //select image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
      });
    }
  }

  //upload post
  void uploadPost(){
    if(imagePickedFile == null|| textController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Both Image and Caption are required!")));
      return;
    }

    //create a new post object
    final newPost = Post(
      text: textController.text,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: '',
      userId: currentUser!.uid,
      userName: currentUser!.name,
      timeStamp: DateTime.now(),
    );

    //post cubit to create new post
     final postCubit = context.read<PostCubit>();
     postCubit.createPost(newPost , imagePath: imagePickedFile?.path);
  }

  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit , PostState>(
        builder: (context, state){
          //loading or uploading
          if(state is PostsLoading || state is PostsUploading){
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          //build upload page
          return buildUploadPage();
        },

        listener: (context, state){
          if(state is PostsLoaded){
            Navigator.pop(context);
          }
        }
    );
  }

  Widget buildUploadPage(){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload))
        ],
      ),

      //body
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //image preview
              if(imagePickedFile != null)
                Image.file(File(imagePickedFile!.path!)),
        
              //pick image button
        
              MaterialButton(
                  onPressed: pickImage,
                  color: Theme.of(context).colorScheme.inversePrimary,
                child: Text("Pick images!", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
              ),
        
              //caption text box
        
              MyTextField(controller: textController, hintText: "Add Caption", obscureText: false),
        
        
        
        
            ],
          ),
        ),
      ),



    );
  }
}
