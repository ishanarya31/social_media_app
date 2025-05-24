import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/features/auth/domain/auth_repos/auth_repo.dart';

import '../domain/entities/app_user.dart';

class FirebaseAuthRepo implements AuthRepo{

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    // TODO: implement loginWithEmailPassword
    try{
      //attempt sign-in
      UserCredential userCredential = await firebaseAuth.
      signInWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(
          uid: userCredential.user!.uid, email: email, name: '');

      return user;
    }
    catch(e){
      throw Exception('Login Failed: $e');
    }
  }
  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async {
    // TODO: implement registerWithEmailPassword
    try{
      //attempt sign-up
      UserCredential userCredential = await firebaseAuth.
      createUserWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(
          uid: userCredential.user!.uid, email: email, name: name);

      //save user in firestore
      await firebaseFirestore.collection("users").doc(user.uid).set(user.toJson());

      //return user
      return user;
    }
    catch(e){
      throw Exception('Login Failed: $e');
    }
  }
  @override
  Future<void> logout() async{
    // TODO: implement logout
    await firebaseAuth.signOut();
  }
  @override
  Future<AppUser?> getCurrentUser() async {
    // TODO: implement currentUser
    final firebaseUser = firebaseAuth.currentUser;

    //no user logged in
    if(firebaseUser == null){
      return null;
    }
    // user exists
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!, name: '');
  }
}