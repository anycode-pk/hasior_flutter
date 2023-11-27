import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../classes/global_snackbar.dart';
import '../services/api_service.dart';
import '../theme.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final _formKey = GlobalKey<FormState>();
  final firstDate = DateTime.now();
  final lastDate = DateTime(DateTime.now().year + 120);
  Image? image;
  File? imageFile;
  bool _isLoading = false;
  DateTime? eventTimeData;
  TextStyle textStyle = const TextStyle(fontSize: 16);
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController localizationController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController eventTimeController = TextEditingController();

  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate);

  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.input,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() {
        imageFile = imageTemporary;
        this.image = Image.file(imageTemporary);
      });
    } on PlatformException catch (e) {
      GlobalSnackbar.errorSnackbar(context, "Błąd podczas wybierania obrazu");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Dodaj nowe wydarzenie"), centerTitle: true),
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Form(
              key: _formKey,
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nazwa", style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Wprowadź nazwę";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Nazwa",
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text("Cena", style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                          decimal: true,
                        ),
                        controller: priceController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return "Wprowadź cenę";
                        //   }
                        //   return null;
                        // },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Cena",
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text("Opis", style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        controller: descriptionController,
                        maxLines: 5,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return "Wprowadź opis";
                        //   }
                        //   return null;
                        // },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Opis",
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text("Lokalizacja", style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        controller: localizationController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return "Wprowadź lokalizację";
                        //   }
                        //   return null;
                        // },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Lokalizacja",
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text("Link do strony", style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        controller: linkController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return "Wprowadź link do strony";
                        //   }
                        //   return null;
                        // },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Link do strony",
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text("Data wydarzenia", style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        readOnly: true,
                        controller: eventTimeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Wprowadź datę wydarzenia";
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? date = await pickDate();
                          if (date == null) return;
                          TimeOfDay? time = await pickTime();
                          if (time == null) return;
                          final dateTime = DateTime(date.year, date.month,
                              date.day, time.hour, time.minute);
                          setState(() {
                            eventTimeData = dateTime;
                          });
                          eventTimeController.value = TextEditingValue(
                              text:
                                  "${DateFormat.yMd(AppLocalizations.of(context)!.localeName).format(DateTime.parse(dateTime.toIso8601String()))} ${DateFormat.Hm(AppLocalizations.of(context)!.localeName).format(DateTime.parse(dateTime.toIso8601String()))}",
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                    offset: dateTime.toString().length),
                              ));
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Data wydarzenia",
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text("Zdjęcie wydarzenia", style: textStyle),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white)),
                            onPressed: () => pickImage(),
                            child: Text("Dodaj zdjęcie"),
                          )),
                      const SizedBox(height: 15),
                      image != null
                          ? Container(
                              height: 120,
                              width: 120,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: image!.image,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.25),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                        ),
                                      ],
                                    ),
                                    height: 100,
                                    width: 100,
                                    child: null,
                                  ),
                                  Align(
                                    alignment: Alignment(1.5, -1),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          image = null;
                                        });
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        color: primarycolor,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            scaffoldBackgroundColor,
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(10),
                                      ),
                                    ),
                                  )
                                ],
                              ))
                          : Container(),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              textStyle: const TextStyle(fontSize: 15)),
                          icon: _isLoading
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Container(),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate() &&
                                      eventTimeData != null) {
                                    try {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var response = await ApiService()
                                          .createEvent(
                                              nameController.text,
                                              double.tryParse(priceController
                                                  .text
                                                  .replaceAll(",", "")),
                                              descriptionController.text,
                                              localizationController.text,
                                              linkController.text,
                                              eventTimeData!,
                                              imageFile);
                                      if (response && context.mounted) {
                                        GlobalSnackbar.infoSnackbar(context,
                                            "Pomyślnie utworzono wydarzenie");
                                      } else {
                                        GlobalSnackbar.infoSnackbar(context,
                                            "Nie udało się utworzyć wydarzenia");
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    } on FormatException catch (e) {
                                      GlobalSnackbar.errorSnackbar(context,
                                          "Błąd podczas tworzenia wydarzenia: ${e.message}");
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                          label: _isLoading
                              ? const Text("")
                              : Text("Utwórz wydarzenie"),
                        ),
                      ),
                      const SizedBox(height: kBottomNavigationBarHeight + 20)
                    ],
                  ))),
        )
      ]),
    );
  }
}
