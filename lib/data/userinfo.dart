class UserInfo {
  final int id;
  final String username;
  final String date_joined;
  final String email;
  final String profile_image_url;
  final List<dynamic> followers;
  final List<dynamic> followings;
  String status;

  UserInfo({this.id, this.username, this.date_joined, this.email, this.profile_image_url, this.followers, this.followings, this.status});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      username: json['username'],
      date_joined: json['date_joined'],
      email: json['email'],
      profile_image_url: json['profile_image_url'],
      followers: json['followers'],
      followings: json['followings'],
      status: json['status'],
    );
  }
}