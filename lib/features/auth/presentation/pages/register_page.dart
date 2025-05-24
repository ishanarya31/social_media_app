import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final confirmPwController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  //register button pressed
  void register(){
    //prepare info
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    //Auth cubit
    final authCubit = context.read<AuthCubit>();

    //ensure fields aren't empty
    if(name.isNotEmpty && email.isNotEmpty && pw.isNotEmpty && confirmPw.isNotEmpty ){
      if(pw == confirmPw){
        authCubit.register(name, email, pw);
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all the fields.")));
    }
  }

  @override
  void dispose(){
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //BODY
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_open_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              
                  const SizedBox(height: 50,),
                  //create Account
                  Text("Let's create an account for you",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20
                      )
                  ),
              
                  const SizedBox(height: 25,),
                  //name field
                  MyTextField(controller: nameController, hintText: "Name", obscureText: false),
              
                  const SizedBox(height: 10),
              
                  //email text field
                  MyTextField(controller: emailController, hintText: "Email", obscureText: false),
              
                  const SizedBox(height: 10),
              
                  //pw text field
                  MyTextField(controller: pwController, hintText: "Password", obscureText: true),
              
                  const SizedBox(height: 10),
                  //confirm pw field
                  MyTextField(controller: confirmPwController, hintText: "Confirm Password", obscureText: true),
              
                  const SizedBox(height: 25),
                  //login button
                  MyButton(onTap: register , text: "Register"),
              
                  const SizedBox(height: 25),
                  //register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already a Member?", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      GestureDetector(
                          onTap: widget.togglePages,
                          child: Text(" Login", style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary , fontWeight: FontWeight.bold))),
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
