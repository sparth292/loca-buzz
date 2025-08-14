import 'package:flutter/material.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = [
      {
        'customer': 'Rahul Sharma',
        'lastMessage': 'Hi, when will my order be ready?',
        'time': '10:30 AM',
        'unread': true,
        'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      },
      {
        'customer': 'Priya Patel',
        'lastMessage': 'Thanks for the great service!',
        'time': 'Yesterday',
        'unread': false,
        'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
      },
    ];

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search messages...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        
        // Active Now Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text('Active Now', style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Text('See All', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        
        // Active Users
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: 3,
            itemBuilder: (context, index) {
              final users = [
                {'name': 'Rahul', 'online': true, 'avatar': 'https://randomuser.me/api/portraits/men/1.jpg'},
                {'name': 'Priya', 'online': true, 'avatar': 'https://randomuser.me/api/portraits/women/2.jpg'},
                {'name': 'Amit', 'online': false, 'avatar': 'https://randomuser.me/api/portraits/men/3.jpg'},
              ][index];
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(users['avatar'] as String),
                        ),
                        if (users['online'] as bool)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      users['name'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Recent Chats
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Recent Chats', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        
        // Conversation List
        Expanded(
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(convo['avatar'] as String),
                  radius: 28,
                ),
                title: Text(
                  convo['customer'] as String,
                  style: TextStyle(
                    fontWeight: convo['unread'] as bool ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  convo['lastMessage'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      convo['time'] as String,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (convo['unread'] as bool)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  // TODO: Navigate to chat screen
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
