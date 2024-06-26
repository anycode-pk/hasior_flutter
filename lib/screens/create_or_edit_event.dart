import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/category.dart';
import 'package:hasior_flutter/models/event.dart';
import 'package:hasior_flutter/screens/home_screen.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_chips_input/select_chips_input.dart';

import '../classes/global_snackbar.dart';
import '../constants/language_constants.dart';
import '../services/api_service.dart';
import '../theme.dart';

class CreateOrEditEvent extends StatefulWidget {
  final Event? event;
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
  List<int> categoryIndexes = List.empty(growable: true);
  List<Category>? categories;
  bool isLoadedCategories = false;
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setForm();
  }

  Future<void> _getCategories() async {
    try {
      categories = await ApiService().getCategories();
      setState(() {
        isLoadedCategories = true;
      });
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
    }
  }

  Future<void> _setForm() async {
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
      image = _setImageFile();
    }
  }

  Image? _setImageFile() {
    if (widget.event == null) {
      return null;
    }
    if (widget.event!.images == null || widget.event!.images!.isEmpty) {
      return null;
    }
    return Image.network(widget.event!.images!.first.path);
  }

  List<int>? preselectCategories() {
    if (categories == null ||
        widget.event == null ||
        widget.event!.categories == null) {
      return null;
    }
    List<int> result = [];
    for (var id in widget.event!.categories!) {
      final index = categories!.indexWhere((element) => element.id == id);
      if (index != -1) {
        result.add(index);
      }
    }
    return result;
  }

  Future<void> _createNewEvent() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<int> selectedCategories = categoryIndexes
          .map((index) {
            if (index >= 0 && index < categories!.length) {
              return categories![index].id;
            } else {
              return null;
            }
          })
          .whereType<int>()
          .toList();
      Event? response = await ApiService().createEvent(
          nameController.text,
          double.tryParse(priceController.text.replaceAll(",", "")),
          descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
          localizationController.text.isEmpty
              ? null
              : localizationController.text,
          linkController.text.isEmpty ? null : linkController.text,
          eventTimeData!,
          selectedCategories);
      if (response == null && context.mounted) {
        GlobalSnackbar.errorSnackbar(
            context, translation(context).failed_to_create_event.capitalize());
        setState(() {
          _isLoading = false;
        });
        return;
      }
      bool responseImage = await uploadImage(response!.id, true);
      if (responseImage && context.mounted) {
        GlobalSnackbar.successSnackbar(
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

  Future<void> _editEvent() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<int> selectedCategories = categoryIndexes
          .map((indeks) {
            if (indeks >= 0 && indeks < categories!.length) {
              return categories![indeks].id;
            } else {
              return null;
            }
          })
          .whereType<int>()
          .toList();
      bool response = await ApiService().editEvent(
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
          eventTimeData!,
          selectedCategories);
      if (response == false && context.mounted) {
        GlobalSnackbar.errorSnackbar(
            context, translation(context).failed_to_edit_event.capitalize());
        setState(() {
          _isLoading = false;
        });
        return;
      }
      bool responseImage = await uploadImage(widget.event!.id, false);
      if (responseImage && context.mounted) {
        GlobalSnackbar.successSnackbar(
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

  Future<bool> uploadImage(int id, bool isNew) async {
    if (imageFile == null &&
        image == null &&
        widget.event!.images != null &&
        widget.event!.images!.isNotEmpty &&
        !isNew) {
      bool response = await ApiService().putNullImageToEvent(id);
      if (!response) {
        return false;
      }
      return true;
    }
    if (imageFile == null) {
      return true;
    }
    bool responseImage = await ApiService().postImageToEvent(id, imageFile!);
    if (!responseImage) {
      return false;
    }
    return true;
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
  Future<void> pickImage() async {
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
      body: OfflineBuilder(connectivityBuilder: (
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
      }, builder: (BuildContext context) {
        return Visibility(
            visible: isLoadedCategories,
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: CustomScrollView(slivers: [
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                                    !RegExp(r'^\d+\.?\d{0,2}')
                                        .hasMatch(value)) {
                                  return translation(context)
                                      .enter_valid_price
                                      .capitalize();
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText:
                                    translation(context).price.capitalize(),
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
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: translation(context)
                                    .description
                                    .capitalize(),
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
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText:
                                    translation(context).location.capitalize(),
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
                                hintText: translation(context)
                                    .link_to_page
                                    .capitalize(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(translation(context).categories.capitalize(),
                                style: textStyle),
                            const SizedBox(height: 10),
                            categories != null && categories!.isNotEmpty
                                ? SizedBox(
                                    width: double.infinity,
                                    child: SelectChipsInput(
                                      chipsText: categories!
                                          .map((e) => e.name)
                                          .toList(),
                                      separatorCharacter: ".",
                                      preSelectedChips: preselectCategories(),
                                      onTap: (p0, p1) {
                                        setState(() {
                                          if (categoryIndexes.any(
                                              (element) => element == p1)) {
                                            categoryIndexes.remove(p1);
                                          } else {
                                            categoryIndexes.add(p1);
                                          }
                                        });
                                      },
                                      marginBetweenChips:
                                          const EdgeInsets.all(5),
                                      prefixIcons: categories != null
                                          ? [
                                              for (var i in categories!)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 5.0),
                                                  child: Icon(
                                                    Icons
                                                        .check_box_outline_blank_outlined,
                                                    size: 16.0,
                                                  ),
                                                )
                                            ]
                                          : null,
                                      selectedPrefixIcon: const Padding(
                                        padding: EdgeInsets.only(right: 5.0),
                                        child: Icon(
                                          Icons.check_box,
                                          size: 16.0,
                                        ),
                                      ),
                                      widgetContainerDecoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                        color: Colors.transparent,
                                        border: Border.all(color: Colors.white),
                                      ),
                                      unselectedChipDecoration: BoxDecoration(
                                        color: primarycolor.withAlpha(100),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      selectedChipDecoration: BoxDecoration(
                                        color: primarycolor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ))
                                : Text(
                                    translation(context)
                                        .no_categories_available
                                        .capitalize(),
                                    style: const TextStyle(
                                        color: grayColor,
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic)),
                            const SizedBox(height: 15),
                            Text(
                                "${translation(context).event_date.capitalize()}*",
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
                                TimeOfDay? time = await pickTime(
                                    eventTimeData != null
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
                                      side: const BorderSide(
                                          color: Colors.white)),
                                  onPressed: () => pickImage(),
                                  child: Text(translation(context)
                                      .add_picture
                                      .capitalize()),
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
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5.0)),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.25),
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
                                        if (!_formKey.currentState!
                                                .validate() ||
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
            ]));
      }),
    );
  }
}
