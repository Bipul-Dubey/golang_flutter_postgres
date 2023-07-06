import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'employee_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:my_form/api_url.dart';


class MyForm extends StatefulWidget {
  const MyForm({Key? key}) : super(key: key);

  @override
  State<MyForm> createState() => MyFormState();
}

enum Genders{Male,Female,Others}

class MyFormState extends State<MyForm> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController= TextEditingController();
  final TextEditingController _fromDateController= TextEditingController();
  final TextEditingController _toDateController= TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  File? _selectedResume;

  //validate name
  bool validateName(String? name){
    final RegExp regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9 ]*$');

    return regex.hasMatch(name!) && name.trim().isNotEmpty;
  }

  // email validation
  bool validateEmail(String? email) {
    RegExp emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@xenonstack.com$');
    return emailRegex.hasMatch(email!);
  }

  // number validation
  bool validateNumber(value){
    if (value.length!=10){
      return false;
    }
    else if(double.tryParse(value) == null){
      return false;
    }
    return true;
  }

  // date pickers
  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days:365*30)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');

      if (isFromDate) {
        setState(() {
          _selectedFromDate = pickedDate;
          _fromDateController.text = formatter.format(pickedDate);
        });
      }
      else {
        setState(() {
          _selectedToDate = pickedDate;
          _toDateController.text = formatter.format(pickedDate);
        });
      }
    }
  }

  List<PlatformFile>? _paths;
  Future<void> uploadFile() async{
    try {
      _paths =(await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus)=>Fluttertoast.showToast(msg: 'Uploading File'),
        allowedExtensions: ['png','pdf']
      )) ?.files;
    }on PlatformException catch(e){
      Fluttertoast.showToast(
              msg: 'unsupported operation$e',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
            );
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
      );
    }
  }

  //clear form fields
  void clearForm(){
    _fullNameController.clear();
    _fromDateController.clear();
    _toDateController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    setState(() {
      _gender = Genders.Others;
    });
    _paths=null;
  }

  // send data
  Future<void> submitForm() async {
    if(_formKey.currentState!.validate()) {
      if(_paths==null){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please Upload a File')),
        );
      }

      FormData data= FormData.fromMap({
        'fullname': _fullNameController.text.trim(),
        'gender': _gender.toString().split('.').last,
        'from_date': _fromDateController.text,
        'to_date': _toDateController.text,
        'email': _emailController.text,
        'number': _phoneNumberController.text,
        'resume': await MultipartFile.fromBytes(_paths!.first.bytes!, filename: _paths!.first.name),
      });

      const url = base_api;
      Dio dio = Dio();
      try {
        Response response= await dio.post(url,data: data,);
        if(response.statusCode!=201){
          Fluttertoast.showToast(
            msg: 'Unsuccessful - Something Went Wrong',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
          );
        }
        else{
          _formKey.currentState!.reset();
          Fluttertoast.showToast(
            msg: 'Successful Submitted',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
          );
          clearForm();
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      }
    }
  }

  Genders? _gender=Genders.Others;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Employee Form'),
        ),
        body: Center(
          child: Container(
          color: const Color.fromARGB(255, 239, 251, 253),
          constraints: const BoxConstraints(maxWidth: 550),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    label: const Text('Full Name'),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,color: Colors.white
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: const Icon(Icons.person)
                  ),
                  validator: (value){
                    if(!validateName(value)){
                      return 'Please Enter Your Name';
                    }
                    return null;
                  },
                ),
                Column(
                  children: [
                    const SizedBox(height: 13,),
                    const Text('Gender',style: TextStyle(fontSize: 20),),
                    Row(
                      children: [
                        Expanded(child: RadioListTile(
                          title: const Icon(Icons.man_2_rounded,size: 40,color: Colors.blue,),
                          value: Genders.Male,
                          groupValue: _gender,
                          onChanged: (value){
                            setState(() {
                              _gender=value;
                            });
                          },
                        )),
                        Expanded(child: RadioListTile(
                            title: const Icon(Icons.woman_2_rounded,size: 40,color: Colors.pink,),
                            value: Genders.Female,
                            groupValue: _gender,
                            onChanged: (value){
                              setState(() {
                                _gender=value;
                              });
                            })),
                        Expanded(child: RadioListTile(
                            title: const Icon(Icons.transgender_rounded,size: 35,),
                            value: Genders.Others,
                            groupValue: _gender,
                            onChanged: (value){
                              setState(() {
                                _gender=value;
                              });
                            })),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12.0,),
                TextFormField(
                  controller: _fromDateController,
                  decoration: InputDecoration(
                    labelText: 'From Date',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,color: Colors.white
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: const Icon(Icons.date_range)
                  ),
                  readOnly: true,
                  onTap: () {
                    selectDate(context, true);
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the from date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0,),
                TextFormField(
                  controller: _toDateController,
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,color: Colors.white
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: const Icon(Icons.date_range)
                  ),
                  readOnly: true,
                  onTap: () {
                    selectDate(context, false);
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the to date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0,),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,color: Colors.white
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: const Icon(Icons.phone_android)
                  ),
                  validator: (String? value) {
                    if(!validateNumber(value)){
                      return 'Enter 10-Digit Number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0,),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,color: Colors.white
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: const Icon(Icons.email)
                  ),
                  validator: (String? value) {
                    if (!validateEmail(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                    onPressed: uploadFile,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        textStyle: const TextStyle(fontSize: 18,color: Colors.black),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                        )
                    ),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Resume')),
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      )
                  ),
                  icon: const Icon(Icons.done),
                  onPressed: submitForm,
                  label: const Text('Submit'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      )
                  ),
                  label: const Text('View Data'),
                  icon: const Icon(Icons.data_object),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SecondRoute()),
                    );
                  },
                ),
              ],
            ),
          ),
        )
          ),
    );
  }
}