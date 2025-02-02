import 'dart:convert';

// LatestAppInfoAPIModel

class LatestAppInfoAPIModel {
  String? version;
  String? buildNumber;
  bool? forceToUpdate;
  bool? removeCacheOnUpdate;
  bool? removeDataOnUpdate;
  bool? removeCacheAndDataOnUpdate;
  String? downloadLink;
  List<DownloadLinkList>? downloadLinkList;

  LatestAppInfoAPIModel({
    this.version,
    this.buildNumber,
    this.forceToUpdate,
    this.removeCacheOnUpdate,
    this.removeDataOnUpdate,
    this.removeCacheAndDataOnUpdate,
    this.downloadLink,
    this.downloadLinkList,
  });

  LatestAppInfoAPIModel copyWith({
    String? version,
    String? buildNumber,
    bool? forceToUpdate,
    bool? removeCacheOnUpdate,
    bool? removeDataOnUpdate,
    bool? removeCacheAndDataOnUpdate,
    String? downloadLink,
    List<DownloadLinkList>? downloadLinkList,
  }) =>
      LatestAppInfoAPIModel(
        version: version ?? this.version,
        buildNumber: buildNumber ?? this.buildNumber,
        forceToUpdate: forceToUpdate ?? this.forceToUpdate,
        removeCacheOnUpdate: removeCacheOnUpdate ?? this.removeCacheOnUpdate,
        removeDataOnUpdate: removeDataOnUpdate ?? this.removeDataOnUpdate,
        removeCacheAndDataOnUpdate:
            removeCacheAndDataOnUpdate ?? this.removeCacheAndDataOnUpdate,
        downloadLink: downloadLink ?? this.downloadLink,
        downloadLinkList: downloadLinkList ?? this.downloadLinkList,
      );

  factory LatestAppInfoAPIModel.fromJson(String str) =>
      LatestAppInfoAPIModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LatestAppInfoAPIModel.fromMap(Map<String, dynamic> json) =>
      LatestAppInfoAPIModel(
        version: json['version'],
        buildNumber: json['buildNumber'],
        forceToUpdate: json['forceToUpdate'],
        removeCacheOnUpdate: json['removeCacheOnUpdate'],
        removeDataOnUpdate: json['removeDataOnUpdate'],
        removeCacheAndDataOnUpdate: json['removeCacheAndDataOnUpdate'],
        downloadLink: json['downloadLink'],
        downloadLinkList: json['downloadLinkList'] == null
            ? []
            : List<DownloadLinkList>.from(json['downloadLinkList']!
                .map((x) => DownloadLinkList.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        'version': version,
        'buildNumber': buildNumber,
        'forceToUpdate': forceToUpdate,
        'removeCacheOnUpdate': removeCacheOnUpdate,
        'removeDataOnUpdate': removeDataOnUpdate,
        'removeCacheAndDataOnUpdate': removeCacheAndDataOnUpdate,
        'downloadLink': downloadLink,
        'downloadLinkList': downloadLinkList == null
            ? []
            : List<dynamic>.from(downloadLinkList!.map((x) => x.toMap())),
      };
}

class DownloadLinkList {
  String? architecture;
  String? link;

  DownloadLinkList({
    this.architecture,
    this.link,
  });

  DownloadLinkList copyWith({
    String? architecture,
    String? link,
  }) =>
      DownloadLinkList(
        architecture: architecture ?? this.architecture,
        link: link ?? this.link,
      );

  factory DownloadLinkList.fromJson(String str) =>
      DownloadLinkList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DownloadLinkList.fromMap(Map<String, dynamic> json) =>
      DownloadLinkList(
        architecture: json['architecture'],
        link: json['link'],
      );

  Map<String, dynamic> toMap() => {
        'architecture': architecture,
        'link': link,
      };
}
