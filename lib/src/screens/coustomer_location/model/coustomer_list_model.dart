import 'dart:convert';

class CoustomerListModel {
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

  CoustomerListModel({
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
  });

  CoustomerListModel copyWith({
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
  }) =>
      CoustomerListModel(
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
      );

  factory CoustomerListModel.fromJson(String str) =>
      CoustomerListModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CoustomerListModel.fromMap(Map<String, dynamic> json) =>
      CoustomerListModel(
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
      };
}
