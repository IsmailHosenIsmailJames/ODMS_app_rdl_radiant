import 'dart:convert';

class CustomerDetailsModel {
  String? partner;
  String? name1;
  String? name2;
  String? contactPerson;
  String? street;
  String? street1;
  String? street2;
  String? street3;
  String? postCode;
  String? upazilla;
  String? district;
  String? mobileNo;
  String? email;
  String? drugRegNo;
  String? customerGrp;
  String? transPZone;
  DateTime? createdOn;
  String? createdAt;
  String? updatedAt;
  double? latitude;
  double? longitude;

  CustomerDetailsModel({
    this.partner,
    this.name1,
    this.name2,
    this.contactPerson,
    this.street,
    this.street1,
    this.street2,
    this.street3,
    this.postCode,
    this.upazilla,
    this.district,
    this.mobileNo,
    this.email,
    this.drugRegNo,
    this.customerGrp,
    this.transPZone,
    this.createdOn,
    this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
  });

  CustomerDetailsModel copyWith({
    String? partner,
    String? name1,
    String? name2,
    String? contactPerson,
    String? street,
    String? street1,
    String? street2,
    String? street3,
    String? postCode,
    String? upazilla,
    String? district,
    String? mobileNo,
    String? email,
    String? drugRegNo,
    String? customerGrp,
    String? transPZone,
    DateTime? createdOn,
    String? createdAt,
    String? updatedAt,
    double? latitude,
    double? longitude,
  }) =>
      CustomerDetailsModel(
        partner: partner ?? this.partner,
        name1: name1 ?? this.name1,
        name2: name2 ?? this.name2,
        contactPerson: contactPerson ?? this.contactPerson,
        street: street ?? this.street,
        street1: street1 ?? this.street1,
        street2: street2 ?? this.street2,
        street3: street3 ?? this.street3,
        postCode: postCode ?? this.postCode,
        upazilla: upazilla ?? this.upazilla,
        district: district ?? this.district,
        mobileNo: mobileNo ?? this.mobileNo,
        email: email ?? this.email,
        drugRegNo: drugRegNo ?? this.drugRegNo,
        customerGrp: customerGrp ?? this.customerGrp,
        transPZone: transPZone ?? this.transPZone,
        createdOn: createdOn ?? this.createdOn,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  factory CustomerDetailsModel.fromJson(String str) =>
      CustomerDetailsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerDetailsModel.fromMap(Map<String, dynamic> json) =>
      CustomerDetailsModel(
        partner: json["partner"],
        name1: json["name1"],
        name2: json["name2"],
        contactPerson: json["contact_person"],
        street: json["street"],
        street1: json["street1"],
        street2: json["street2"],
        street3: json["street3"],
        postCode: json["post_code"],
        upazilla: json["upazilla"],
        district: json["district"],
        mobileNo: json["mobile_no"],
        email: json["email"],
        drugRegNo: json["drug_reg_no"],
        customerGrp: json["customer_grp"],
        transPZone: json["trans_p_zone"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "partner": partner,
        "name1": name1,
        "name2": name2,
        "contact_person": contactPerson,
        "street": street,
        "street1": street1,
        "street2": street2,
        "street3": street3,
        "post_code": postCode,
        "upazilla": upazilla,
        "district": district,
        "mobile_no": mobileNo,
        "email": email,
        "drug_reg_no": drugRegNo,
        "customer_grp": customerGrp,
        "trans_p_zone": transPZone,
        "created_on":
            "${createdOn!.year.toString().padLeft(4, '0')}-${createdOn!.month.toString().padLeft(2, '0')}-${createdOn!.day.toString().padLeft(2, '0')}",
        "created_at": createdAt,
        "updated_at": updatedAt,
        "latitude": latitude,
        "longitude": longitude,
      };
}
