import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fitness_day/core/constant/app_share_links.dart';

/// Opens the native share sheet so the user can invite friends to the app.
class AppShareService {
  const AppShareService._();

  static Future<void> shareApp(BuildContext context) async {
    final storeLink =
        Platform.isIOS ? AppShareLinks.iosStore : AppShareLinks.androidStore;

    // iPad renders the share sheet as a popover and needs an anchor rect,
    // otherwise it throws. Anchor it to the widget that triggered the share.
    final box = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        text: '${'share.app_message'.tr()}\n$storeLink',
        subject: 'share.app_subject'.tr(),
        sharePositionOrigin: _anchorFor(box),
      ),
    );
  }

  /// Shares a link to a single product.
  static Future<void> shareProduct(
    BuildContext context, {
    required String productId,
    required String productName,
  }) async {
    final box = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        text: '$productName\n${AppShareLinks.product(productId)}',
        subject: productName,
        sharePositionOrigin: _anchorFor(box),
      ),
    );
  }

  static Rect? _anchorFor(RenderBox? box) =>
      box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
}
