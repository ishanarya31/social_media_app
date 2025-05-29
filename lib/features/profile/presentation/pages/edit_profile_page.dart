import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_states.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //mobile image pick
  PlatformFile? imagePickedFile;

  //bio text controller
  final bioTextController = TextEditingController();

  //pick image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
      });
    }
  }

  //update profile button pressed
  void updateProfile() async {
    try {
      final profileCubit = context.read<ProfileCubit>();

      //prepare image and data
      final String uid = widget.user.uid;
      final imageMobilePath = imagePickedFile?.path;
      final String? newBio = bioTextController.text.isNotEmpty
          ? bioTextController.text
          : null;

      if (imagePickedFile != null || newBio != null) {
        profileCubit.updateProfile(
          uid: uid,
          newBio: newBio,
          imageMobilePath: imageMobilePath,
        );
      }
      //nothing to update
      else {
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }

    @override
    void dispose(){
      bioTextController.dispose();
      super.dispose();
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // profile loading
        if (state is ProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text('Uploading...')],
              ),
            ),
          );
        }
        //profile error
        else {
          return buildEditPage();
        }

        //edit form
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          IconButton(
            onPressed: () => updateProfile(),
            icon: Icon(Icons.upload),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              //profile picture
              GestureDetector(
                onTap: () async {
                  await pickImage();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  clipBehavior: Clip.hardEdge,
                  height: 200,
                  width: 200,
        
                  child: (imagePickedFile != null)
                      ? Image.file(File(imagePickedFile!.path!),fit: BoxFit.cover,)
                      : CachedNetworkImage(
                          imageUrl: widget.user.profileImageUrl,
                          //loading..
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
        
                          //error
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 100,
                            color: Theme.of(context).colorScheme.primary,
                          ),
        
                          //loaded
                          imageBuilder: (context, imageProvider) =>
                              Image(image: imageProvider,
                              fit: BoxFit.cover,),
                        ),
                ),
              ),
        
              Text("Click to change Profile Picture!",style: TextStyle(color: Theme.of(context).colorScheme.primary),),
        
              const SizedBox(height: 20),
              //bio
              Row(
                children: [
                  Text(
                    "BIO",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
        
              MyTextField(
                controller: bioTextController,
                hintText: widget.user.bio,
                obscureText: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
