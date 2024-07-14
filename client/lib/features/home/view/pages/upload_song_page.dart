import 'dart:io';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/widget/audio_wave.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<UploadSongPage> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final TextEditingController _songNameController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  Color selectedColor = Pallete.cardColor;
  File? selectedImage;
  File? selectedAudio;
  @override
  void dispose() {
    _songNameController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(homeViewmodelProvider.select((val) => val?.isLoading == true));
    return isLoading
        ? const Loader()
        : Scaffold(
            appBar: AppBar(
              title: const Text("Upload Song"),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () async {
                      if (formkey.currentState!.validate() &&
                          selectedAudio != null &&
                          selectedImage != null) {
                        ref.read(homeViewmodelProvider.notifier).uploadSong(
                            selectedAudio: selectedAudio!,
                            selectedThumbnail: selectedImage!,
                            songName: _songNameController.text,
                            artistName: _artistController.text,
                            selectedColor: selectedColor);
                      } else {
                        showSnackBar(context, "Missing Fields!!");
                      }
                    },
                    icon: const Icon(Icons.check)),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formkey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: selectedImage != null
                            ? SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ))
                            : DottedBorder(
                                color: Pallete.borderColor,
                                radius: const Radius.circular(10),
                                borderType: BorderType.RRect,
                                strokeCap: StrokeCap.round,
                                dashPattern: const [10, 4],
                                child: const SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.folder_open, size: 40),
                                      SizedBox(height: 15),
                                      Text(
                                        "Select the thumbnail for your song",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                      selectedAudio != null
                          ? AuidoWave(path: selectedAudio!.path)
                          : CustomField(
                              onTap: selectAudio,
                              hintText: "Pick Song",
                              controller: null,
                              readOnly: true,
                            ),
                      const SizedBox(height: 20),
                      CustomField(
                          hintText: "Artist", controller: _artistController),
                      const SizedBox(height: 20),
                      CustomField(
                          hintText: "Song Name",
                          controller: _songNameController),
                      const SizedBox(height: 20),
                      ColorPicker(
                        pickersEnabled: const {ColorPickerType.wheel: true},
                        color: selectedColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
