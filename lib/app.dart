import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_states.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/posts/presentation/pages/home_page.dart';
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


  @override
  Widget build(BuildContext context) {

    return BlocProvider(
        create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
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
