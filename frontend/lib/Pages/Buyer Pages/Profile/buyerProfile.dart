import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../Config/config.dart';
import '../../../Theme/ColorTheme.dart';
import 'accountInformation.dart';

class buyerProfile extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? email;
  final int? balance;
  final profilePic;
  final void Function(String, String, int) onUpdate;
  final void Function(String) onProfilePicUpdate;

  const buyerProfile({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.balance,
    required this.profilePic,
    required this.onUpdate,
    required this.onProfilePicUpdate,
  }) : super(key: key);

  @override
  State<buyerProfile> createState() => _buyerProfileState();
}

class _buyerProfileState extends State<buyerProfile> {
  //                           variables

  var _image;
  void initState() {
    super.initState();
    if (widget.profilePic != null) {
      _image = base64Decode(widget.profilePic);
    }
  }

  //                           variables
  Future<void> _pickImage() async {
    try {
      // Pick an image file using file_picker package
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      // If user cancels the picker, do nothing
      if (result == null) return;

      // If user picks an image, update the state with the new image file
      setState(() {
        _image = result.files.first.bytes!;
      });

      List<int> imageBytes = result.files.first.bytes!;
      String imageBase64 = base64Encode(imageBytes);
      widget.onProfilePicUpdate(imageBase64);
      // Send the email and base64-encoded image to the server
      var regbody = {"email": widget.email, "profilePic": imageBase64};
      var response = await http.patch(Uri.parse(updateProfilePic),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regbody));
      if (response.statusCode == 200) {
        print('Image uploaded successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image uploaded successfully.'),
          ),
        );
        // Handle any additional logic after a successful upload
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${response.body} Status code: ${response.statusCode}'),
          ),
        );
        // Handle the error as needed
      }
    } catch (e) {
      // If there is an error, show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  //                           functions
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TextEditingController _controllerFirstName =
        TextEditingController(text: widget.firstName);
    TextEditingController _controllerLastName =
        TextEditingController(text: widget.lastName);
    TextEditingController _controllerBalance =
        TextEditingController(text: widget.balance.toString());

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: mainColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_image != null)
                                  CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Colors.transparent,
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: Image.memory(
                                          Uint8List.fromList(_image!),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_image == null)
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xffe6e0ea),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      // Add your desired image icon here
                                      color: Colors.white,
                                      size: 200,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            widget.firstName!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Balance ${widget.balance}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xffe6e0ea),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      selectedColor: Colors.white,
                      leading: Icon(Icons.account_circle,
                          size: 40.0, color: mainColor),
                      title: Text(
                        'Account Information',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Tap to view details',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return AccountInfoBottomSheet(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              email: widget.email,
                              balance: widget.balance,
                              controllerFirstName: _controllerFirstName,
                              controllerLastName: _controllerLastName,
                              controllerBalance: _controllerBalance,
                              onUpdate: widget.onUpdate,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
