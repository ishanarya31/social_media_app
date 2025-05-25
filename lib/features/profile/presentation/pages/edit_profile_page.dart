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

  final bioTextController = TextEditingController();

  void updateProfile() async{

    final profileCubit = context.read<ProfileCubit>();

    if(bioTextController.text.isNotEmpty){
      profileCubit.updateProfile(uid: widget.user.uid, newBio: bioTextController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit ,ProfileState>(
        builder: (context,state){
          // profile loading
          if(state is ProfileLoading){
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Uploading...')
                  ],
                ),
              ),
            );
          }

          //profile error
          else{
            return buildEditPage();
          }

          //edit form
        },
        listener: (context ,state){
          if(state is ProfileLoaded){
            Navigator.pop(context);
          }
        }
    );
  }

  Widget buildEditPage({double uploadProgress = 0.0}){
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
        actions: [
          IconButton(onPressed: ()=> updateProfile(), icon: Icon(Icons.upload)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            //profile picture

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(100),
              ),
              height: 200,
              width: 200,

              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Center(
                  child: Icon(Icons.person,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,),
                ),
              ),
            ),

            const SizedBox(height: 20,),
            //bio
            Row(
              children: [
                Text(
                  "BIO",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),
                ),
              ],
            ),

            MyTextField(controller: bioTextController, hintText: widget.user.bio, obscureText: false)
          ],
        ),
      ),
    );
  }
}
