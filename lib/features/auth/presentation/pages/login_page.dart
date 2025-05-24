/*

Login page

On this page , an existing user can login with their :
- email + pw

If the user is successfully authenticated , he will go tp the home page.

If the user is not registered , then he can go to the register page.
 */



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/components/my_button.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key , required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final pwController = TextEditingController();

  //login button pressed
  void login(){
    //grab the data from the controllers
    final String email = emailController.text;
    final String pw = pwController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();

    if(email.isNotEmpty && pw.isNotEmpty){
      authCubit.login(email, pw);
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter both email and password!")));
    }
  }

  @override
  void dispose(){
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //BODY
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(Icons.lock_open_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
                ),
              
                const SizedBox(height: 50,),
                //welcome back msg
                Text("Welcome Back ,you've been missed!",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              
                const SizedBox(height: 25,),
                //email text field
                MyTextField(controller: emailController, hintText: "Email", obscureText: false),
              
                const SizedBox(height: 10),
                //pw text field
                MyTextField(controller: pwController, hintText: "Password", obscureText: true),
              
                const SizedBox(height: 25),
                //login button
                MyButton(onTap: login , text: "Login"),
              
                const SizedBox(height: 25),
                //register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Not a member? ", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      GestureDetector(
                        onTap: widget.togglePages,
                          child: Text("Register Now", style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
