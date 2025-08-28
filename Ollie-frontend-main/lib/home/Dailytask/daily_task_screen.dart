import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/home/Dailytask/create_task.dart';
import 'package:ollie/home/Dailytask/daily_task_controller.dart';

extension DateExtensions on DateTime {
  String get weekdayName =>
      ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][weekday - 1];
  String get monthName => [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ][month - 1];
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.put(TodoController());
    DateTime _focusedDate = DateTime.now();

    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BGcolor,
        elevation: 0,
        leading: const BackButton(color: Black),
        centerTitle: false,
        title: const Text("To-Do List", style: TextStyle(color: Black)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3C3129),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const CreateTaskSheet(),
          );
        },
        child: const Icon(Icons.add, color: white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            10.verticalSpace,
            EasyDateTimeLinePicker.itemBuilder(
              firstDate: DateTime(2025, 1, 1),
              lastDate: DateTime(2030, 3, 18),
              focusedDate: _focusedDate,
              itemExtent: 64.0,

              itemBuilder:
                  (context, date, isSelected, isDisabled, isToday, onTap) {
                    return InkResponse(
                      onTap: onTap,
                      child: CircleAvatar(
                        backgroundColor: isSelected ? Colors.blue : null,
                        child: Text(date.day.toString()),
                      ),
                    );
                  },
              onDateChange: (date) {
                setState(() {
                  _focusedDate = date;
                });
              },
            ),

            // Obx(() {
            //   final selected = controller.selectedDate.value;
            //   return Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       "${selected.weekdayName}, ${selected.day} ${selected.monthName} ${selected.year}",
            //       style: const TextStyle(color: Colors.grey),
            //     ),
            //   );
            // }),
            // 20.verticalSpace,

            // /// Date Scroll (30 days)
            // SizedBox(
            //   height: 40.h,
            //   child: Obx(() {
            //     final selected = controller.selectedDate.value;
            //     return ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemCount: 30,
            //       itemBuilder: (context, index) {
            //         final date = DateTime.now().add(Duration(days: index));
            //         final isSelected =
            //             selected.day == date.day &&
            //             selected.month == date.month &&
            //             selected.year == date.year;

            //         return GestureDetector(
            //           onTap: () => controller.setDate(date),
            //           child: Container(
            //             margin: const EdgeInsets.only(right: 12),
            //             width: 40,
            //             decoration: BoxDecoration(
            //               color: isSelected
            //                   ? const Color(0xFFF4BD2A)
            //                   : Colors.grey.shade200,
            //               shape: BoxShape.circle,
            //             ),
            //             alignment: Alignment.center,
            //             child: Text(
            //               "${date.day}",
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 color: isSelected ? Colors.white : Colors.black,
            //               ),
            //             ),
            //           ),
            //         );
            //       },
            //     );
            //   }),
            // ),

            // 20.verticalSpace,

            // /// Task List
            // Expanded(
            //   child: Obx(() {
            //     final tasks = controller.filteredTasks;
            //     return ListView.separated(
            //       itemCount: tasks.length,
            //       separatorBuilder: (_, __) => 10.verticalSpace,
            //       itemBuilder: (context, index) {
            //         final task = tasks[index];
            //         final isDone = task["done"] == true;
            //         final originalIndex = controller.tasks.indexOf(task);

            //         return Row(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             GestureDetector(
            //               onTap: () => controller.toggleTask(originalIndex),
            //               child: Container(
            //                 height: 58.h,
            //                 width: 35.h,
            //                 margin: const EdgeInsets.only(right: 10),
            //                 alignment: Alignment.center,
            //                 child: Icon(
            //                   isDone
            //                       ? Icons.check_circle
            //                       : Icons.radio_button_unchecked,
            //                   color: isDone
            //                       ? const Color(0xFFF4BD2A)
            //                       : Colors.black45,
            //                   size: 28,
            //                 ),
            //               ),
            //             ),
            //             Expanded(
            //               child: GestureDetector(
            //                 onTap: () {
            //                   if (!isDone) {
            //                     showDialog(
            //                       context: context,
            //                       builder: (_) {
            //                         return Dialog(
            //                           backgroundColor: const Color(0xFFFDF3DD),
            //                           shape: RoundedRectangleBorder(
            //                             borderRadius: BorderRadius.circular(20),
            //                           ),
            //                           child: Padding(
            //                             padding: const EdgeInsets.symmetric(
            //                               horizontal: 20,
            //                               vertical: 30,
            //                             ),
            //                             child: Column(
            //                               mainAxisSize: MainAxisSize.min,
            //                               children: [
            //                                 Text(
            //                                   task["text"] as String,
            //                                   textAlign: TextAlign.center,
            //                                   style: const TextStyle(
            //                                     fontWeight: FontWeight.bold,
            //                                     fontSize: 16,
            //                                   ),
            //                                 ),
            //                                 const SizedBox(height: 10),
            //                                 if (task["description"] != null &&
            //                                     task["description"]
            //                                         .toString()
            //                                         .isNotEmpty)
            //                                   Text(
            //                                     task["description"] as String,
            //                                     textAlign: TextAlign.center,
            //                                     style: const TextStyle(
            //                                       fontSize: 13,
            //                                       color: Colors.black87,
            //                                     ),
            //                                   ),
            //                                 const SizedBox(height: 25),
            //                                 ElevatedButton(
            //                                   onPressed: () {
            //                                     controller.toggleTask(
            //                                       originalIndex,
            //                                     );
            //                                     Navigator.pop(context);
            //                                   },
            //                                   style: ElevatedButton.styleFrom(
            //                                     backgroundColor: const Color(
            //                                       0xFF3C3129,
            //                                     ),
            //                                     shape: RoundedRectangleBorder(
            //                                       borderRadius:
            //                                           BorderRadius.circular(30),
            //                                     ),
            //                                     minimumSize: const Size(
            //                                       double.infinity,
            //                                       45,
            //                                     ),
            //                                   ),
            //                                   child: const Text(
            //                                     "Mark as Completed",
            //                                     style: TextStyle(
            //                                       color: Colors.white,
            //                                     ),
            //                                   ),
            //                                 ),
            //                                 const SizedBox(height: 10),
            //                                 OutlinedButton(
            //                                   onPressed: () =>
            //                                       Navigator.pop(context),
            //                                   style: OutlinedButton.styleFrom(
            //                                     side: const BorderSide(
            //                                       color: Colors.black,
            //                                     ),
            //                                     shape: RoundedRectangleBorder(
            //                                       borderRadius:
            //                                           BorderRadius.circular(30),
            //                                     ),
            //                                     minimumSize: const Size(
            //                                       double.infinity,
            //                                       45,
            //                                     ),
            //                                     foregroundColor: Colors.black,
            //                                   ),
            //                                   child: const Text("Cancel"),
            //                                 ),
            //                               ],
            //                             ),
            //                           ),
            //                         );
            //                       },
            //                     );
            //                   }
            //                 },
            //                 child: Container(
            //                   height: 58.h,
            //                   padding: const EdgeInsets.symmetric(
            //                     horizontal: 12,
            //                   ),
            //                   decoration: BoxDecoration(
            //                     color: isDone ? const Color(0xFFFFE38E) : white,
            //                     borderRadius: BorderRadius.circular(30),
            //                     border: Border.all(color: Colors.black12),
            //                   ),
            //                   child: Row(
            //                     mainAxisAlignment:
            //                         MainAxisAlignment.spaceBetween,
            //                     children: [
            //                       Expanded(
            //                         child: Text(
            //                           task["text"] as String,
            //                           overflow: TextOverflow.ellipsis,
            //                           style: const TextStyle(
            //                             fontWeight: FontWeight.w500,
            //                           ),
            //                         ),
            //                       ),
            //                       const SizedBox(width: 10),
            //                       Text(
            //                         task["time"] ?? "9:00 PM",
            //                         style: const TextStyle(
            //                           fontWeight: FontWeight.w500,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         );
            //       },
            //     );
            //   }),
            // ),
          ],
        ),
      ),
    );
  }
}
