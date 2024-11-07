import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/app/routes.dart';
import 'package:task_hub/utils/ui_utils.dart';

import '../../cubits/auth_cubit.dart';
import '../../data/models/note.dart';

class DrawerContainer extends StatefulWidget {
  const DrawerContainer({super.key});

  @override
  State<DrawerContainer> createState() => _DrawerContainerState();
}

class _DrawerContainerState extends State<DrawerContainer> {
  Widget buildItem(String title, IconData icon, Function onTap) {
    return ListTile(
      dense: true,
      isThreeLine: false,
      leading: Icon(
        icon,
        size: 22,
      ),
      title: Text(title,
          style: TextStyle(fontSize: UiUtils.screenSubTitleFontSize + 2)),
      onTap: () {
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var themeData = Theme.of(context);
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            bottom: 10),
        constraints: BoxConstraints(
          maxHeight: size.height,
        ),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: size.height - 100,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    child: Text(
                      'TaskHub',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildItem('Notes', Icons.lightbulb_outline, () {
                    // Navigator.pop(context);
                  }),
                  buildItem('Reminders', Icons.lightbulb_outline, () {
                    // Navigator.pop(context);
                  }),
                  Divider(
                    color: themeData.primaryColorLight,
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Labels',
                          style: themeData.textTheme.titleSmall,
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigator.pop(context);
                          },
                          child: Text(
                            'Edit',
                            style: themeData.textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  if (true)
                    ...List.generate(
                        2,
                        (index) =>
                            buildItem('Label $index', Icons.label_outline, () {
                              // Navigator.pop(context);
                            })),
                  SizedBox(height: 10),
                  buildItem('Create new label', Icons.add, () {
                    // Navigator.pop(context);
                  }),
                  Divider(
                    color: themeData.primaryColorLight,
                  ),
                  SizedBox(height: 10),
                  buildItem('Archive', Icons.archive_outlined, () {
                    // Navigator.pop(context);
                  }),
                  buildItem('Settings', Icons.settings, () {
                    // Navigator.pop(context);
                  }),
                  // Spacer(),
                ],
              ),
            ),
            Container(
              width: size.width * 0.5,
              alignment: Alignment.bottomCenter,
              child: buildItem('Sign out', Icons.logout, () {
                // logout
                context.read<AuthCubit>().signOut();
                Navigator.pushReplacementNamed(context, Routes.login);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
