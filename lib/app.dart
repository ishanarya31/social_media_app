import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media_app/features/profile/data/firebase_profile_repo.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/themes/light_mode.dart';

/*

APP ROOT LEVEL

Repositories: for the dataBase
-firebase

Bloc Providers: for state management
  -auth
  -profile
  -post
  -search
  -theme

Check Auth State
  -unauthenticated -> auth_page
  -authenticated -> home page

 */
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final authRepo = FirebaseAuthRepo();
  final profileRepo = FirebaseProfileRepo();

  @override
  Widget build(BuildContext context) {


    //provide cubits to app
    return MultiBlocProvider(
        providers: [

        //auth cubit
          BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(authRepo: authRepo)..checkAuth()
          ),

        //profile cubit
          BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(profileRepo: profileRepo))
        ],


        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          home: BlocConsumer<AuthCubit, AuthState>(
              builder: (context, authState) {

                print(authState);

                if(authState is Unauthenticated){
                  return const AuthPage();
                }
                if(authState is Authenticated){
                  return const HomePage();
                }
                else{
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
              listener: (context, state){
                if(state is AuthError){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                }
              }
          ),
        )
    );
  }
}
