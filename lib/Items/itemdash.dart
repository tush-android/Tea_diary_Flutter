import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/provider/Itempro.dart' as ask;
import 'package:teadiary/Items/itemadd.dart';

class Itemdash extends StatefulWidget {
  const Itemdash({super.key});

  @override
  State<Itemdash> createState() => _ItemdashState();
}

class _ItemdashState extends State<Itemdash> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<ask.Itempro>(context, listen: false).fetchItems());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ask.Itempro>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Item Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchItems(),
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
            : provider.Items.isEmpty
                ? const Center(
                    child: Text(
                      "No Items Available...!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.Items.length,
                    itemBuilder: (context, index) {
                      final i = provider.Items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.orangeAccent.shade100,
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.orange.shade700,
                                radius: 25,
                                child: const Icon(
                                  Icons.fastfood_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// FIX: Expanded wraps full column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      i['Itemname'] ?? "No Item Available...!",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      i['ItemPrice'] ?? "0000",
                                      style: TextStyle(
                                          color: Colors.redAccent.shade400,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddItem()));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}
