import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/enums/role.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/user.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/theme.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<User> users = [];
  List<User> usersFiltered = [];
  bool isLoaded = false;
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  final TextEditingController _searchController = TextEditingController();

  Future<bool> _getAllUsers() async {
    try {
      setState(() {
        isLoaded = false;
      });
      users = await ApiService().getMultipleUsersData();
      usersFiltered = users;
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                textInputAction: TextInputAction.search,
                controller: _searchController,
                onSubmitted: (value) {
                  usersFiltered = [];
                  for (User element in users) {
                    if (element.email.contains(value)) {
                      usersFiltered.add(element);
                    }
                  }
                  setState(() {});
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  hintText: "${translation(context).search.capitalize()}...",
                  hintStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        _searchController.clear();
                        usersFiltered = users;
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    itemCount: usersFiltered.length,
                    itemBuilder: (context, index) {
                      return _buildCard(usersFiltered[index]);
                    },
                  )),
            )
          ],
        ));
  }

  Card _buildCard(User user) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: Text(user.email, style: const TextStyle(fontSize: 20)),
          ),
          subtitle: Wrap(
              runSpacing: 1,
              spacing: 5,
              children: List.generate(user.roles.length, (index) {
                return Chip(
                  label: Text(user.roles[index].name),
                  backgroundColor: grayColor,
                );
              })),
          trailing: _buttonWidget(user),
        ),
      ),
    );
  }

  Widget? _buttonWidget(User user) {
    return !_isAdmin(user)
        ? Ink(
            decoration: const ShapeDecoration(
              color: primarycolor,
              shape: CircleBorder(),
            ),
            child: IconButton(
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
                      GlobalSnackbar.errorSnackbar(
                          context,
                          translation(context)
                              .error_while_loading
                              .capitalize());

                      return false;
                    }
                  }
                });
              },
            ))
        : null;
  }

  bool _isAdmin(User user) {
    return user.roles.contains(Role.ADMIN);
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
      content: Text(translation(context).new_moderator_question.capitalize()),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}
