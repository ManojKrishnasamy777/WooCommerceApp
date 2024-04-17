import 'dart:convert';

import 'package:e_com/core/core.dart';
import 'package:e_com/models/settings/payment_model.dart';
import 'package:e_com/models/settings/shipping_model.dart';
import 'package:e_com/models/settings/ui_section_model.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'region_model.dart';

class ConfigModel {
  ConfigModel({
    required this.settings,
    required this.paymentMethods,
    required this.languages,
    required this.defaultLanguage,
    required this.currency,
    required this.shippingData,
    required this.extraPages,
    required this.socialContacts,
    required this.promotionalBanners,
    required this.coupons,
    required this.frontendSection,
  });

  static Map<String, dynamic>? _parseFrontEnd(
    Map<String, dynamic> map,
    String slug,
  ) {
    final frontEndData =
        List<Map<String, dynamic>>.from(map['frontend_section']['data']);
    final parsed = frontEndData.firstWhere(
      (map) => map['slug'] == slug,
      orElse: () => {'slug': 404},
    );

    return parsed[slug] == 404 ? null : parsed['value'];
  }

  static List<String?> _parsePromotionalOffer(Map<String, dynamic> map) {
    final data = _parseFrontEnd(map, 'promotional-offer');

    final imgs = data?.entries
        .where((e) => e.key.contains('image'))
        .map((e) => <String, dynamic>{'name': e.key, ...e.value})
        .map((e) => e['value'])
        .toList();

    return List<String?>.from(imgs ?? [null, null]);
  }

  static List<SocialIcon> _parseSocialIcons(Map<String, dynamic> map) {
    final data = _parseFrontEnd(map, 'social-icon');

    final parsed = data?.entries
        .where((element) => (element.value).keys.contains('icon'))
        .map((e) => <String, dynamic>{'name': e.key, ...e.value})
        .map((e) => SocialIcon.fromMap(e))
        .toList();

    return List<SocialIcon>.from(parsed ?? []);
  }

  factory ConfigModel.fromJson(String source) =>
      ConfigModel.fromMap(json.decode(source));

  factory ConfigModel.fromMap(Map<String, dynamic> map) {
    return ConfigModel(
      settings: SettingsModel.fromMap(map['settings']),
      paymentMethods: List<PaymentData>.from(
        map['payment_methods']['data']?.map((x) => PaymentData.fromMap(x)),
      ),
      languages: Languages.fromMap(map['languages']),
      defaultLanguage: LanguagesData.fromMap(map['default_language']),
      currency: Currencies.fromMap(map['currency']),
      shippingData: ShippingMethods.fromMap(map['shipping_data']),
      extraPages: List<ExtraPagesModel>.from(
          map['pages']['data']?.map((x) => ExtraPagesModel.fromMap(x))),
      socialContacts: _parseSocialIcons(map),
      promotionalBanners: _parsePromotionalOffer(map),
      coupons: List<Coupon>.from(
        map['coupons']?['data'].map((x) => Coupon.fromMap(x)),
      ),
      frontendSection: FrontendSection.fromMap(map['frontend_section']),
    );
  }

  final List<Coupon> coupons;
  final Currencies currency;
  final LanguagesData defaultLanguage;
  final List<ExtraPagesModel> extraPages;
  final Languages languages;
  final List<PaymentData> paymentMethods;
  final SettingsModel settings;
  final ShippingMethods shippingData;
  final List<SocialIcon> socialContacts;
  final List<String?> promotionalBanners;
  final FrontendSection frontendSection;

  ExtraPagesModel? get tncPage =>
      extraPages.where((x) => x.uid == '1dRR-7BkgK045-kV4k').firstOrNull;

  Map<String, dynamic> toMap() {
    return {
      'settings': settings.toMap(),
      'payment_methods': {
        'data': paymentMethods.map((x) => x.toMap()).toList()
      },
      'languages': languages.toMap(),
      'default_language': defaultLanguage.toMap(),
      'currency': currency.toMap(),
      'shipping_data': shippingData.toMap(),
      'pages': {'data': extraPages.map((x) => x.toMap()).toList()},
      'coupons': {'data': coupons.map((x) => x.toMap()).toList()},
      'frontend_section': {
        'data': [
          {
            'slug': 'promotional-offer',
            'value': {
              for (int i = 0; i < promotionalBanners.length; i++)
                'image$i': {'value': promotionalBanners[i]}
            },
          },
          {
            'slug': 'social-icon',
            'value': {
              for (var icon in socialContacts) icon.name: icon.toMap(),
            },
          },
          ...frontendSection.toMappedList()
        ],
      },
    };
  }

  String toJson() => json.encode(toMap());
}

class ExtraPagesModel {
  ExtraPagesModel({
    required this.description,
    required this.name,
    required this.uid,
  });

  factory ExtraPagesModel.fromJson(String source) =>
      ExtraPagesModel.fromMap(json.decode(source));

  factory ExtraPagesModel.fromMap(Map<String, dynamic> map) {
    return ExtraPagesModel(
      uid: map['uid'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  final String description;
  final String name;
  final String uid;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'description': description,
      };

  String toJson() => json.encode(toMap());
}

class SettingsModel {
  SettingsModel({
    required this.siteName,
    required this.siteLogo,
    required this.cashOnDelivery,
    required this.address,
    required this.copyrightText,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontColor,
    required this.email,
    required this.phone,
    required this.orderIdPrefix,
    required this.filterMinRange,
    required this.filterMaxRange,
    required this.googleOAuth,
    required this.facebookOAuth,
    required this.onBoarding,
    required this.guestCheckout,
    required this.phoneOTP,
    required this.emailOTP,
    required this.isPasswordEnabled,
  });

  factory SettingsModel.fromJson(String source) =>
      SettingsModel.fromMap(json.decode(source));

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      siteName: map['site_name'] ?? '',
      siteLogo: map['site_logo'] ?? '',
      cashOnDelivery: map['cash_on_delevary'] == 'active',
      guestCheckout: map['guest_checkout'] ?? false,
      address: map['address'] ?? '',
      copyrightText: map['copyright_text'] ?? '',
      primaryColor: ((map['primary_color'] ?? '') as String).toColorK(),
      fontColor: ((map['font_color'] ?? '') as String).toColorK(),
      secondaryColor: ((map['secondary_color'] ?? '') as String).toColorK(),
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      orderIdPrefix: map['order_id_prefix'] ?? '',
      filterMinRange: intFromAny(map['filter_min_range']),
      filterMaxRange: intFromAny(map['filter_max_range']),
      googleOAuth: GoogleOAuth.fromMap(map['google_oauth']),
      facebookOAuth: FacebookOAuth.fromMap(map['facebook_oauth']),
      onBoarding: List<OneBoardingData>.from(
          map['onboarding_pages'].map((x) => OneBoardingData.fromMap(x))),
      emailOTP: map['email_otp'] ?? false,
      phoneOTP: map['phone_otp'] ?? false,
      isPasswordEnabled: map['login_with_password'] ?? false,
    );
  }

  final String address;
  final bool cashOnDelivery;
  final bool guestCheckout;
  final String copyrightText;
  final String email;
  final String phone;
  final FacebookOAuth? facebookOAuth;
  final int filterMaxRange;
  final int filterMinRange;
  final GoogleOAuth? googleOAuth;
  final List<OneBoardingData> onBoarding;
  final String orderIdPrefix;
  final Color? fontColor;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String siteLogo;
  final String siteName;
  final bool phoneOTP;
  final bool emailOTP;
  final bool isPasswordEnabled;

  Map<String, dynamic> toMap() => {
        'site_name': siteName,
        'site_logo': siteLogo,
        'guest_checkout': guestCheckout,
        'cash_on_delevary': cashOnDelivery ? 'active' : 'inactive',
        'address': address,
        'copyright_text': copyrightText,
        'primary_color': primaryColor?.hex,
        'secondary_color': secondaryColor?.hex,
        'font_color': fontColor?.hex,
        'email': email,
        'phone': phone,
        'order_id_prefix': orderIdPrefix,
        'filter_min_range': filterMinRange,
        'filter_max_range': filterMaxRange,
        'google_oauth': googleOAuth?.toMap(),
        'facebook_oauth': facebookOAuth?.toMap(),
        'onboarding_pages': onBoarding.map((x) => x.toMap()).toList(),
        'email_otp': emailOTP,
        'phone_otp': phoneOTP,
        'login_with_password': isPasswordEnabled,
      };

  String toJson() => json.encode(toMap());
}

class SocialIcon {
  final String icon;
  final String name;
  final String url;

  SocialIcon({
    required this.icon,
    required this.url,
    required this.name,
  });

  factory SocialIcon.fromMap(Map<String, dynamic> map) {
    return SocialIcon(
      icon: map['icon'],
      url: map['url'],
      name: map['name'],
    );
  }
  Map<String, dynamic> toMap() => {
        'icon': icon,
        'url': url,
        'name': name,
      };
}

class OneBoardingData {
  OneBoardingData({
    required this.image,
    required this.heading,
    required this.description,
  });

  factory OneBoardingData.fromJson(String source) =>
      OneBoardingData.fromMap(json.decode(source));

  factory OneBoardingData.fromMap(Map<String, dynamic> map) {
    return OneBoardingData(
      image: map['image'] ?? '',
      heading: map['heading'] ?? '',
      description: map['description'] ?? '',
    );
  }

  final String description;
  final String heading;
  final String image;

  Map<String, dynamic> toMap() => {
        'image': image,
        'heading': heading,
        'description': description,
      };

  String toJson() => json.encode(toMap());
}

class GoogleOAuth {
  GoogleOAuth({
    required this.gClientId,
    required this.gClientSecret,
    required this.gStatus,
  });

  static GoogleOAuth? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    if (map.isEmpty) return null;
    return GoogleOAuth(
      gClientId: map['g_client_id'] ?? '',
      gClientSecret: map['g_client_secret'] ?? '',
      gStatus: map['g_status'] ?? '',
    );
  }

  final String gClientId;
  final String gClientSecret;
  final String gStatus;

  Map<String, dynamic> toMap() => {
        'g_client_id': gClientId,
        'g_client_secret': gClientSecret,
        'g_status': gStatus,
      };

  String toJson() => json.encode(toMap());
}

class FacebookOAuth {
  FacebookOAuth({
    required this.fClientId,
    required this.fClientSecret,
    required this.fStatus,
  });

  static FacebookOAuth? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    if (map.isEmpty) return null;
    return FacebookOAuth(
      fClientId: map['f_client_id'] ?? '',
      fClientSecret: map['f_client_secret'] ?? '',
      fStatus: map['f_status'] ?? '',
    );
  }

  final String fClientId;
  final String fClientSecret;
  final String fStatus;

  Map<String, dynamic> toMap() => {
        'f_client_id': fClientId,
        'f_client_secret': fClientSecret,
        'f_status': fStatus,
      };

  String toJson() => json.encode(toMap());
}

class Coupon {
  Coupon({
    required this.uid,
    required this.name,
    required this.code,
    required this.discount,
    required this.discountType,
  });

  final String uid;
  final String name;
  final String code;
  final int discount;
  final String discountType;

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      discount: intFromAny(map['discount']),
      discountType: map['discount_type'] ?? '',
    );
  }
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'code': code,
        'discount': discount,
        'discount_type': discountType,
      };
}
