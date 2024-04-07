import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/thred.dart';
import 'package:hasior_flutter/models/ticket.dart';
import 'package:hasior_flutter/screens/add_thred_screen.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/widgets/image_thred_widget.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';
import '../theme.dart';

class Partners extends StatefulWidget {
  const Partners({super.key});

  @override
  State<Partners> createState() => _PartnersState();
}

class _PartnersState extends State<Partners> {
  List<Thred> data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(translation(context).partners.capitalize()),
          centerTitle: true,
        ),
        body: OfflineBuilder(
          connectivityBuilder: (
            BuildContext context,
            ConnectivityResult connectivity,
            Widget child,
          ) {
            if (connectivity == ConnectivityResult.none) {
              return OfflineWidget(
                child: child,
              );
            } else {
              return child;
            }
          },
          builder: (BuildContext context) {
            return FutureBuilder(
                future: _getData(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    return RefreshIndicator(
                      onRefresh: _getData,
                      child: _createMainContainer(),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled:true,
                builder: (BuildContext context) {
                  return AddThred();
                },
              );
          },
          child: Icon(Icons.add),
          backgroundColor: theme.primaryColor,
        ));
  }

  Widget _createMainContainer() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
        child: ListView.builder(
          itemCount: data.length, // Adjust the number of cards as needed
          itemBuilder: (BuildContext context, int index) {
            return ImageThredWidget(
              imagePath:
                  'assets/logo.png', // Assuming you have images named as image1.jpg, image2.jpg, etc.
              text: data[index].text,
            );
          },
        ));
  }

  Future<bool> _getData() async {
    try {
      data = await ApiService().getThreds([2]) ?? [];
      return true;
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
      return false;
    }
  }
}
