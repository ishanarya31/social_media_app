import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/profile/presentation/components/bio_box.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_states.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key ,required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  //current user
  late AppUser? currentUser = authCubit.currentUser;

  //on startup,
  @override
  void initState(){
    super.initState();

    //load user profile data
    profileCubit.fetchUserProfile(widget.uid);

  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context,state){

          //loaded

          if(state is ProfileLoaded){
            //get loaded user
            final user = state.profileUser;


            return Scaffold(
              appBar: AppBar(
                title: Text(user.name),
                foregroundColor: Theme.of(context).colorScheme.primary,
                actions: [
                  IconButton(onPressed: ()=> Navigator.push(context,MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user,))),
                      icon: const Icon(Icons.edit))
                ],
              ),

              //Body
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(user.email,
                      style: TextStyle(color:Theme.of(context).colorScheme.primary,),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20,),

                      //profile pic

                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          clipBehavior: Clip.hardEdge,
                          height: 200,
                          width: 200,
                          child: CachedNetworkImage(
                            imageUrl: user.profileImageUrl,
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

                      const SizedBox(height: 20,),

                      //bio box
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

                      BioBox(bio: user.bio),

                      const SizedBox(height: 15,),

                      //posts
                      Row(
                        children: [
                          Text(
                            "POSTS",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),

            );
          }


          //loading
          else if(state is ProfileLoading){
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          else{
            return const Center(
              child: Text("No Profile found.."),
            );
          }


        }
    );
  }
}
