  class PostModel {
  final int id;
  final int categoryId;
  final String? categoryName;
  final String title;
  final String content;
  final String? image;
  final String author;
  final String? createdAt;

  PostModel({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.title,
    required this.content,
    this.image,
    required this.author,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
      author: json['author'] ?? 'Anonim',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'content': content,
      'image': image,
      'author': author,
    };
  }
}