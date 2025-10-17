import 'package:get/get.dart';

class VolunteerController extends GetxController {
  // List of selected volunteers (multiple can be selected)
  final RxSet<String> selectedVolunteers = <String>{}.obs;

  void toggleSelection(String name) {
    if (selectedVolunteers.contains(name)) {
      selectedVolunteers.remove(name);
    } else {
      selectedVolunteers.add(name);
    }
  }

  bool isSelected(String name) => selectedVolunteers.contains(name);
}
