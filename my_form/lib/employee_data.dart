import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:my_form/api_url.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Employee Data'),
        ),
        body: const EmpData()
    );
  }
}

class EmpData extends StatefulWidget{
  const EmpData({Key? key}) : super(key:key);

  @override
  State<EmpData> createState() => EmpDataPage();
}

class EmpDataPage extends State<EmpData>{
  // employee list that holds each employee data
  List<Map<String, dynamic>> emps = [];

  // get employee data from api
  Future<List<Map<String,dynamic>>> getData() async{
    emps=[];
    final response = await http.get(Uri.parse(base_api));

    if(response.statusCode==200){
      var data= jsonDecode(response.body);
      emps=List<Map<String,dynamic>>.from(data);
    }
    return emps;
  }

  // download resume file -- given url
  Future<void> downloadFile(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final String fileName = url.split('/').last;

    if (response.statusCode == 200) {
      Directory? directory = await getExternalStorageDirectory();
      File file = File('${directory!.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      Fluttertoast.showToast(
        msg: 'Download in : ${directory.path}/$fileName',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
    else {
      Fluttertoast.showToast(
        msg: 'Download Failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.lightBlueAccent[100]),
                  headingTextStyle: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold,fontSize: 15),
                  dividerThickness: 2,
                  columns: const [
                    DataColumn(label: Text('Form ID')),
                    DataColumn(label: Text('Full Name')),
                    DataColumn(label: Text('Gender')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('From Date')),
                    DataColumn(label: Text('To Date')),
                    DataColumn(label: Text('Number')),
                    DataColumn(label: Text('Resume')),
                  ],
                  rows: emps.map((emp) {
                    return DataRow(cells: [
                      DataCell(Text('${emp['ID']}')),
                      DataCell(Text('${emp['fullname']}')),
                      DataCell(Text('${emp['gender']}')),
                      DataCell(Text('${emp['email']}')),
                      DataCell(Text('${emp['from_date']}')),
                      DataCell(Text('${emp['to_date']}')),
                      DataCell(Text('${emp['number']}')),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            if(kIsWeb){
                              final anchor= html.AnchorElement(href:'$file_api/${emp['file']}');
                              anchor.download = emp['file'];
                              anchor.click();
                            }else{
                              downloadFile('$file_api/${emp['file']}');
                            }
                          },
                          child: const Icon(Icons.download_rounded),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
          else{
            return const Center(child: CircularProgressIndicator(),);
          }
        }
    );
  }
}
