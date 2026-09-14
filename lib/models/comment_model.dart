class CommentModel {
  final int id;
  final String content;
  final CommentUserModel? user;
  final String? createdAt;

  CommentModel({
    required this.id,
    required this.content,
    this.user,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      user: json['user'] != null ? CommentUserModel.fromJson(json['user']) : null,
      createdAt: json['createdAt'],
    );
  }
}

class CommentUserModel {
  final int? id;
  final String? name;
  final String? picture;

  CommentUserModel({this.id, this.name, this.picture});

  factory CommentUserModel.fromJson(Map<String, dynamic> json) {
    return CommentUserModel(
      id: json['id'],
      name: json['name'],
      picture: json['picture'],
    );
  }
}
