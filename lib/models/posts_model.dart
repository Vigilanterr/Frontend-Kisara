class PostModel {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final String title;
  final String content;
  final String? picture;
  final AuthorModel? author;
  final int? likeCount;
  final int? commentCount;
  final String? createdAt;

  PostModel({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.title,
    required this.content,
    this.picture,
    this.author,
    this.likeCount,
    this.commentCount,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      title: json['title'],
      content: json['content'],
      picture: json['picture'],
      author: json['author'] != null ? AuthorModel.fromJson(json['author']) : null,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'],
    );
  }
}

class AuthorModel {
  final int? id;
  final String? name;
  final String? picture;

  AuthorModel({this.id, this.name, this.picture});

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'],
      name: json['name'],
      picture: json['picture'],
    );
  }
}
