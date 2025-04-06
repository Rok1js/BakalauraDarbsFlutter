class Post {
  final int id;
  final String title;
  final String content;
  final String category;
  final DateTime publishedAt;
  final String imgUrl;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.publishedAt,
    required this.imgUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      publishedAt: DateTime.parse(json['published_at']),
      imgUrl: 'https://admin.gofinanceapp.lv${json['img_url']}',
    );
  }
}