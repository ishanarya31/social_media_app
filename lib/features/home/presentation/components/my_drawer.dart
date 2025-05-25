import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'my_drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              Divider(color: Theme.of(context).colorScheme.primary),

              //home tile
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),

              Divider(color: Theme.of(context).colorScheme.primary),

              //profile tile
              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person_2,
                onTap: () {
                  //pop menu drawer
                  Navigator.of(context).pop();

                  //getting the user id
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  //navigating to the user profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
                  );
                },
              ),

              Divider(color: Theme.of(context).colorScheme.primary),

              //search tile
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: () {},
              ),

              Divider(color: Theme.of(context).colorScheme.primary),

              //settings tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {},
              ),

              const Spacer(),

              //logout tile
              MyDrawerTile(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: () {
                  context.read<AuthCubit>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
