class Person {
  String name;
  String mail;
  String phone;
  String? nickname;

  Person(
      {required this.name,
      required this.mail,
      required this.phone,
      this.nickname});

  static fromMap(data) {
    try {
      String nick = data['nickname'];
    }
    catch (e) {
      String nick = data['name'];
    }
    return Person(
      name: data['name'],
      mail: data['mail'],
      phone: data['phone'],
      nickname: data['nickname'],
    );
  }

  toMap() {
    return {
      'name': name,
      'mail': mail,
      'phone': phone,
      'nickname': nickname,
    };
  }

  static Person dummyPerson() {
    return Person(
      name: "",
      mail: "",
      phone: "",
    );
  }
}
