import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:teadiary/dashmenu/newcus.dart';
import 'package:teadiary/provider/Customerpro.dart' as ask;

class cusdash extends StatefulWidget {
  const cusdash({super.key});

  @override
  State<cusdash> createState() => _cusdashState();
}

class _cusdashState extends State<cusdash> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ask.Cusmanage>(context, listen: false).fetchcustomers());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ask.Cusmanage>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Customer's"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchcustomers(),
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              )
            : provider.customers.isEmpty
                ? const Center(
                    child: Text(
                      "No Customers Found!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.customers.length,
                    itemBuilder: (context, index) {
                      final c = provider.customers[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.orangeAccent.shade100,
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.orange.shade700,
                                radius: 25,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['name'] ?? 'No Name',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: Color.fromARGB(255, 228, 77, 67),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Expanded(
                                          child: Text(
                                        c['mobile'] ?? "No Mobileno...",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.blueAccent),
                                      )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Colors.greenAccent,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Expanded(
                                          child: Text(
                                        c['address'] ?? "No Address",
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.blue),
                                      ))
                                    ],
                                  )
                                ],
                              )),
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
              context, MaterialPageRoute(builder: (_) => addnewcus()));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
