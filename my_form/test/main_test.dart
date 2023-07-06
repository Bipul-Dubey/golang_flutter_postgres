import 'package:flutter_test/flutter_test.dart';
import 'package:my_form/employee_data.dart';
import 'package:my_form/employee_form.dart';


void main(){
  MyFormState form =MyFormState();
  test('validateEmail should return true/false for valid/invalid email addresses',() {
    expect(form.validateEmail('john.doe@example.com'), isFalse);
    expect(form.validateEmail('jane_smith@xenonstack.com'), isTrue);
    expect(form.validateEmail('test.user1234@xenonstack.com'), isTrue);
  });

  test('validateNumber should return true/false for valid/invalid email addresses',() {
    expect(form.validateNumber('123456'), isFalse);
    expect(form.validateNumber('9123456708'), isTrue);
    expect(form.validateNumber('12345asdfg'), isFalse);
  });

  test('validateName should return true/false for valid/invalid name',() {
    expect(form.validateName('123 456'), isFalse);
    expect(form.validateName('     '), isFalse);
    expect(form.validateName('123 Name'), isFalse);
    expect(form.validateName('Test Name'), isTrue);
    expect(form.validateName('Test Name123'), isTrue);
  });

  EmpDataPage emp=EmpDataPage();
  test('return success message if data receive Successfully', () async {
    expect(await emp.getData(),isNotEmpty);
  });

}