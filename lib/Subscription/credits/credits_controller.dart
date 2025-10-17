import 'package:get/get.dart';

enum PlanType { free, basic, advanced }

class SubscriptionController extends GetxController {
  var selectedPlan = PlanType.free.obs;

  List<String> get planBenefits {
    switch (selectedPlan.value) {
      case PlanType.free:
        return ['10 credits per month', 'Limited no. of reads per month (Blogs & Articles)'];
      case PlanType.basic:
        return ['25 credits per month', 'Unlimited reads per month (Blogs & Articles)'];
      case PlanType.advanced:
        return ['50 credits per month', 'Unlimited reads per month (Blogs & Articles)', 'No ads'];
    }
  }

  void selectPlan(PlanType plan) {
    selectedPlan.value = plan;
  }
}
