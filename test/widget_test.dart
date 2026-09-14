import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/category_chip.dart';
import 'package:frontend/models/posts_model.dart';
import 'package:frontend/widgets/post_card.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('CategoryChip renders label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChip(
            label: 'Teknologi',
            isSelected: false,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Teknologi'), findsOneWidget);
  });

  testWidgets('PostCard renders title and content', (WidgetTester tester) async {
    final post = PostModel(
      id: 1,
      title: 'Judul Artikel',
      content: 'Isi artikel',
      categoryName: 'Teknologi',
      likeCount: 5,
      commentCount: 3,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostCard(post: post, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Judul Artikel'), findsOneWidget);
    expect(find.text('Isi artikel'), findsOneWidget);
    expect(find.text('Teknologi'), findsOneWidget);
  });
}
