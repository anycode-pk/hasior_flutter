import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/user.dart';
import 'package:hasior_flutter/services/api_service.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<User> users = [];
  bool isLoaded = false;
  final String _admin = "ADMIN";

  Future<bool> _getAllUsers() async {
    try {
      setState(() {
        isLoaded = false;
      });
      users = await ApiService().getMultipleUsersData();

      setState(() {
        isLoaded = true;
      });
      return true;
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());

      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translation(context).manage_students.capitalize()),
        centerTitle: true,
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return Visibility(
        visible: isLoaded,
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
        child: Container(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return _buildCard(users[index]);
              },
            )));
  }

  Container _buildCard(User user) {
    return Container(
      child: Card(
        child: ListTile(
          title: Text(user.email),
          subtitle: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1.5,
              child: Row(
                  children: user.roles
                      .map((e) => Chip(
                            label: Text(e.name),
                          ))
                      .toList())),
          trailing: _buttonWidget(user),
        ),
      ),
    );
  }

  Widget? _buttonWidget(User user) {
    return !_isAdmin(user)
        ? IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _createAlertDialog(context, user);
                },
              ).then((value) {
                if (value != null) {
                  try {
                    setState(() {
                      ApiService()
                          .addUserToRole(value.id)
                          .then((value) => _getAllUsers());
                    });
                    return true;
                  } catch (e) {
                    GlobalSnackbar.errorSnackbar(context,
                        translation(context).error_while_loading.capitalize());

                    return false;
                  }
                }
              });
            },
          )
        : null;
  }

  bool _isAdmin(User user) {
    return user.roles.any((element) => element.name == _admin);
  }

  Widget _createAlertDialog(BuildContext context, User user) {
    Widget cancelButton = TextButton(
      child: Text(translation(context).no.capitalize()),
      onPressed: () {
        Navigator.pop(context, null);
      },
    );
    Widget continueButton = TextButton(
      child: Text(translation(context).yes.capitalize()),
      onPressed: () {
        Navigator.pop(context, user);
      },
    );

    return AlertDialog(
      title: Text(translation(context).new_moderator.capitalize()),
      content:
          Text(translation(context).new_moderator_question.capitalize()),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}
