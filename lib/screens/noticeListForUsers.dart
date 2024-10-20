import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoticesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notices')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('notice').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var notices = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              var notice = notices[index];
              return ListTile(
                title: Text(notice['heading']),
                subtitle: Text(notice['content']),
              );
            },
          );
        },
      ),
    );
  }
}
