import 'package:flutter/foundation.dart';

class RequestItem {
  final int id;
  final String addressMap;
  final String description;
  final int citizenId;
  final int imageId;
  final int statusId;
  final bool isClosed;
  final String createdAt;
  final Citizen citizen;
  final Request category;
  final Request mahalla;
  final RequestStatus status;
  final Img image;

  RequestItem({
    @required this.id,
    @required this.addressMap,
    @required this.description,
    @required this.citizenId,
    @required this.imageId,
    @required this.statusId,
    @required this.isClosed,
    @required this.createdAt,
    @required this.citizen,
    @required this.mahalla,
    @required this.category,
    @required this.status,
    @required this.image
  });

  factory RequestItem.fromJson(Map<String, dynamic> categoryItemJson) =>
      RequestItem(
        id: categoryItemJson['id'],
        addressMap: categoryItemJson['addressMap'],
        description: categoryItemJson['description'],
        citizenId: categoryItemJson['citizenId'],
        imageId: categoryItemJson['imageId'],
        statusId: categoryItemJson['statusId'],
        isClosed: categoryItemJson['isClosed'],
        createdAt: categoryItemJson['createdAt'],
        citizen: Citizen.fromJson(categoryItemJson['citizen']),
        category: Request.fromJson(categoryItemJson['category']),
        mahalla: Request.fromJson(categoryItemJson['mahalla']),
        // mahalla: Request(
        //   id: 1,
        //   nameUz: "Uzbek",
        //   nameRu: "Russian",
        //   nameEn: "English"
        // ),
        status: RequestStatus.fromJson(categoryItemJson['status']),
        image: Img.fromJson(categoryItemJson['image']),
      );
}

class Request {
  final int id;
  final String nameUz;
  final String nameRu;
  final String nameEn;

  Request({
    this.id,
    this.nameUz,
    this.nameRu,
    this.nameEn
  });

  factory Request.fromJson(Map<String, dynamic> categoryJson) => Request(
      id: categoryJson['id'],
      nameUz: categoryJson['name_uz'],
      nameRu: categoryJson['name_ru'],
      nameEn: categoryJson['name_en']
  );
}

class RequestStatus {
  final int id;
  final String nameUz;
  final String nameRu;
  final String nameEn;

  RequestStatus({
    this.id,
    this.nameUz,
    this.nameRu,
    this.nameEn
  });

  factory RequestStatus.fromJson(Map<String, dynamic> categoryJson) => RequestStatus(
      id: categoryJson['id'],
      nameUz: categoryJson['name_uz'],
      nameRu: categoryJson['name_ru'],
      nameEn: categoryJson['name_en']
  );
}

class Citizen {
  final int id;
  final String name;
  final String surname;

  Citizen({
    this.id,
    this.name,
    this.surname
  });

  factory Citizen.fromJson(Map<String, dynamic> citizen) => Citizen(
    id: citizen['id'],
    name: citizen['name'],
    surname: citizen['surname'],
  );
}

class Img {
  final int id;
  final String imageUrl;

  Img({this.id, this.imageUrl});

  factory Img.fromJson(Map<String, dynamic> imageJson) => Img(
      id: imageJson['id'],
      imageUrl: imageJson['imageUrl']
  );
}

class Requests with ChangeNotifier {
  List<RequestItem> _item = [];

  List<RequestItem> get item {
    return _item;
  }
}