import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guide_up/services/firebase_firestore.dart';

class ViewRequests extends StatefulWidget {
  const ViewRequests({super.key});

  @override
  State<ViewRequests> createState() => _ViewRequestsState();
}

class _ViewRequestsState extends State<ViewRequests> {
  final RequestService _requestService = RequestService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    List<Map<String, dynamic>> fetchedRequests = await _requestService.fetchRequests();
    setState(() {
      requests = fetchedRequests;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8, top: 10, bottom: 30),
                      child: Text(
                        'Requests',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    Text(
                      'You have ${requests.length} requests',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    requests.isEmpty
                        ? const Center(child: Text("No requests found"))
                        : Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                final request = requests[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blueAccent, width: 2),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(request["image"]!),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  request["name"]!,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  request["requirment"] ?? "No reason provided",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              String mentorId = FirebaseAuth.instance.currentUser!.uid;
                                              String menteeId = request["menteeId"];
                                              String requestId = request["requestId"];

                                              try {
                                                await _requestService.assignMentee(mentorId, menteeId);
                                                await FirebaseFirestore.instance
                                                    .collection('MentorRequests')
                                                    .doc(requestId)
                                                    .update({'status': 'accepted'});

                                                setState(() {
                                                  requests.removeAt(index);
                                                });

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("Accepted ${request["name"]} as your mentee")),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("Error accepting request: $e")),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                            ),
                                            child: const Text("Accept", style: TextStyle(color: Colors.white)),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              String requestId = request["requestId"];
                                              try {
                                                await _requestService.deleteRequest(requestId);
                                                setState(() {
                                                  requests.removeAt(index);
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("Rejected ${request["name"]}")),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("Error deleting request: $e")),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                            ),
                                            child: const Text("Reject", style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
