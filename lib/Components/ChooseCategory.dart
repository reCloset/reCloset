import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Types/CommonTypes.dart';
import '../Data/ListingProvider.dart';

List<String> categoryList =
    ItemCategory.values.map((e) => e.displayName).toList();

class ChooseCategory extends StatefulWidget {
  final List<String> items;

  const ChooseCategory({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<ChooseCategory> createState() => _ChooseCategoryState();
}

class _ChooseCategoryState extends State<ChooseCategory> {
  String dropdownValue = categoryList.first;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 220, 220, 220),
          borderRadius: BorderRadius.circular(5),
        ),
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.arrow_downward),
          style: const TextStyle(color: Colors.black),
          onChanged: (String? value) {
            setState(() {
              dropdownValue = value!;
              Provider.of<ListingProvider>(context, listen: false).category =
                  value;
            });
          },
          items: categoryList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));
  }
}
