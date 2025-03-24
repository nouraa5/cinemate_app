import 'package:flutter/material.dart';
import '../../widgets/nav_bar_scaffold.dart'; // Adjust path as needed

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({Key? key}) : super(key: key);

  final List<Map<String, String>> faqList = const [
    {
      'question': 'How do I book a ticket?',
      'answer':
          'To book a ticket, navigate to the movie page and tap the "Book Now" button. Follow the instructions to select your seats and complete the payment.'
    },
    {
      'question': 'What payment methods are accepted?',
      'answer':
          'We accept all major credit/debit cards as well as various mobile payment options for a seamless transaction.'
    },
    {
      'question': 'How can I view my bookings?',
      'answer':
          'You can view your bookings by tapping on the "Bookings" option in the bottom navigation bar or from the sidebar under "My Bookings".'
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'For support, please email us at support@cinemate.com or use the in-app contact form under the "Help" section.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return NavBarScaffold(
      title: "Help / FAQ",
      body: ListView.builder(
        itemCount: faqList.length,
        itemBuilder: (context, index) {
          final faq = faqList[index];
          return ExpansionTile(
            title: Text(
              faq['question']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  faq['answer']!,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
            iconColor: Colors.orange,
            collapsedIconColor: Colors.white54,
          );
        },
      ),
    );
  }
}
