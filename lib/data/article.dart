class Article {
  String emotion;
  String location;
  String menu;
  String weather;
  String song;
  int point;
  String content;
  int id;
  String image;
  String created;
  List<dynamic> liked;
  int user;

  Article({this.emotion, this.location, this.menu, this.weather, this.song, this.point, this.content, this.id, this.image, this.created, this.liked, this.user});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      emotion: json['emotion'],
      location: json['location'],
      menu: json['menu'],
      weather: json['weather'],
      song: json['song'],
      point: json['point'],
      content: json['content'],
      id: json['id'],
      image: json['image'],
      created: json['created'],
      liked: json['liked'],
      user: json['user'],
    );
  }
}