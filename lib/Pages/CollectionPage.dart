import 'package:flutter/material.dart';
import 'package:recloset/Components/BottomNavigationBar.dart';
import 'package:recloset/Components/Collection.dart';
import 'package:recloset/Components/ItemCard.dart';

import 'ItemDetail.dart';

class CollectionPage extends StatefulWidget {
  final String title;
  final bool isSearch;
  final List<ItemCardData> collection;
  final String searchQuery;

  const CollectionPage({
    Key? key,
    required this.collection,
    required this.title,
    this.isSearch = false,
    this.searchQuery = "",
  }) : super(key: key);

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        bottomNavigationBar: AppNavigationBar(
          selectedIndex: 0,
          onItemTapped: (int) {
            Navigator.of(context).pop();
          },
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            if (widget.isSearch)
              Container(
                  margin: const EdgeInsets.all(10),
                  child: Text(
                    "Showing results for: ${widget.searchQuery}",
                    style: const TextStyle(fontSize: 20),
                  )),
            GridView.count(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                scrollDirection: Axis.vertical,
                children: widget.collection
                    .where((item) => item.name.toLowerCase().contains(widget.searchQuery.toLowerCase()))
                    .map((item) => InkWell(
                        child: ItemCard(
                          imagePath: item.imagePath,
                          name: item.name,
                          credits: item.credits,
                        ),
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ItemDetail(id: item.id),
                            ))))
                    .toList())
          ],
        ));
  }
}
