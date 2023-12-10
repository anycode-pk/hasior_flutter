import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/events.dart';
import 'package:hasior_flutter/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../classes/global_snackbar.dart';
import '../constants/language_constants.dart';
import '../services/api_service.dart';
import '../theme.dart';

class CreateOrEditEvent extends StatefulWidget {
  final Events? event;
  const CreateOrEditEvent({super.key, this.event});

  @override
  State<CreateOrEditEvent> createState() => _CreateOrEditEventState();
}

class _CreateOrEditEventState extends State<CreateOrEditEvent> {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setForm();
  }

  Future _setForm() async {
    if (widget.event != null) {
      nameController.text = widget.event!.name;
      priceController.text =
          widget.event!.price == null ? "" : widget.event!.price.toString();
      descriptionController.text = widget.event!.description ?? "";
      localizationController.text = widget.event!.localization ?? "";
      linkController.text = widget.event!.ticketsLink ?? "";
      eventTimeData = DateTime.parse(widget.event!.eventTime);
      eventTimeController.value = TextEditingValue(
          text:
              "${DateFormat.yMd(AppLocalizations.of(context)!.localeName).format(DateTime.parse(widget.event!.eventTime))} ${DateFormat.Hm(AppLocalizations.of(context)!.localeName).format(DateTime.parse(widget.event!.eventTime))}",
          selection: TextSelection.fromPosition(
            TextPosition(offset: widget.event!.eventTime.length),
          ));
      await _getData(widget.event!.id);
    }
  }

  Future<File?> _getData(int id) async {
    try {
      imageFile = await ApiService().getFileByEventId(id);
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
    }
  }

  Future _createNewEvent() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await ApiService().createEvent(
          nameController.text,
          double.tryParse(priceController.text.replaceAll(",", "")),
          descriptionController.text,
          localizationController.text,
          linkController.text,
          eventTimeData!,
          imageFile);
      if (response && context.mounted) {
        GlobalSnackbar.infoSnackbar(
            context,
            translation(context)
                .event_has_been_successfully_created
                .capitalize());
        Navigator.pop(context, true);
      } else {
        GlobalSnackbar.errorSnackbar(
            context, translation(context).failed_to_create_event.capitalize());
      }
      setState(() {
        _isLoading = false;
      });
    } on FormatException catch (e) {
      GlobalSnackbar.errorSnackbar(context,
          "${translation(context).an_error_occurred_during_creating_event.capitalize()}: ${e.message}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _editEvent() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await ApiService().editEvent(
          widget.event!.id,
          nameController.text,
          priceController.text.isEmpty
              ? null
              : double.tryParse(priceController.text.replaceAll(",", "")),
          descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
          localizationController.text.isEmpty
              ? null
              : localizationController.text,
          linkController.text.isEmpty ? null : linkController.text,
          eventTimeData!);
      if (response && context.mounted) {
        GlobalSnackbar.infoSnackbar(
            context,
            translation(context)
                .event_has_been_successfully_edited
                .capitalize());
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      } else {
        GlobalSnackbar.errorSnackbar(
            context, translation(context).failed_to_edit_event.capitalize());
      }
      setState(() {
        _isLoading = false;
      });
    } on FormatException catch (e) {
      GlobalSnackbar.errorSnackbar(context,
          "${translation(context).an_error_occurred_during_editing_event.capitalize()}: ${e.message}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<DateTime?> pickDate([DateTime? initialDate]) => showDatePicker(
      context: context,
      initialDate: initialDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate);

  Future<TimeOfDay?> pickTime([TimeOfDay? initialTime]) => showTimePicker(
        context: context,
        initialTime: initialTime ?? TimeOfDay.now(),
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
    } on PlatformException {
      GlobalSnackbar.errorSnackbar(context,
          translation(context).error_while_selecting_a_photo.capitalize());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.event == null
              ? translation(context).add_new_event.capitalize()
              : translation(context).edit_event.capitalize()),
          centerTitle: true),
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
                      Text("${translation(context).name.capitalize()}*",
                          style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return translation(context)
                                .enter_event_name
                                .capitalize();
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText:
                              "${translation(context).name.capitalize()}*",
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(translation(context).price.capitalize(),
                          style: textStyle),
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
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !RegExp(r'^\d+\.?\d{0,2}').hasMatch(value)) {
                            return translation(context)
                                .enter_valid_price
                                .capitalize();
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: translation(context).price.capitalize(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(translation(context).description.capitalize(),
                          style: textStyle),
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
                          hintText:
                              translation(context).description.capitalize(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(translation(context).location.capitalize(),
                          style: textStyle),
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
                          hintText: translation(context).location.capitalize(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(translation(context).link_to_page.capitalize(),
                          style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        controller: linkController,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !(Uri.tryParse(value)?.hasAbsolutePath ??
                                  false)) {
                            return translation(context)
                                .enter_valid_website_link
                                .capitalize();
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText:
                              translation(context).link_to_page.capitalize(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text("${translation(context).event_date.capitalize()}*",
                          style: textStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        cursorColor: Colors.white,
                        readOnly: true,
                        controller: eventTimeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return translation(context)
                                .enter_event_date
                                .capitalize();
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? date = await pickDate(eventTimeData);
                          if (date == null) return;
                          TimeOfDay? time = await pickTime(eventTimeData != null
                              ? TimeOfDay.fromDateTime(eventTimeData!)
                              : null);
                          if (time == null) return;
                          final dateTime = DateTime(date.year, date.month,
                              date.day, time.hour, time.minute);
                          setState(() {
                            eventTimeData = dateTime;
                          });
                          if (!mounted) return;
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
                          hintText:
                              "${translation(context).event_date.capitalize()}*",
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(translation(context).event_photo.capitalize(),
                          style: textStyle),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white)),
                            onPressed: () => pickImage(),
                            child: Text(
                                translation(context).add_picture.capitalize()),
                          )),
                      const SizedBox(height: 15),
                      image != null
                          ? SizedBox(
                              height: 120,
                              width: 120,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(10),
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
                                    alignment: const Alignment(1.5, -1),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          image = null;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            scaffoldBackgroundColor,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                      ),
                                      child: const Icon(
                                        Icons.clear,
                                        color: primarycolor,
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
                                  if (!_formKey.currentState!.validate() ||
                                      eventTimeData == null) {
                                    return;
                                  }
                                  if (widget.event == null) {
                                    await _createNewEvent();
                                  } else {
                                    await _editEvent();
                                  }
                                },
                          label: _isLoading
                              ? const Text("")
                              : Text(widget.event == null
                                  ? translation(context)
                                      .create_event
                                      .capitalize()
                                  : translation(context)
                                      .edit_event
                                      .capitalize()),
                        ),
                      )
                    ],
                  ))),
        )
      ]),
    );
  }
}
