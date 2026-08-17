import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fitness_day/core/constant/app_share_links.dart';

/// Opens the native share sheet so the user can invite friends to the app.
class AppShareService {
  const AppShareService._();

  /// Guards against opening the share sheet multiple times when the user taps
  /// the share button rapidly before the previous sheet has been dismissed.
  static bool _isSharing = false;

  /// Shares [AppShareLinks.openApp] — one link that opens the app on home when
  /// it is installed and falls through to the website (and from there the right
  /// store) when it is not.
  ///
  /// It used to send a store URL chosen from `Platform.isIOS` — the *sender's*
  /// platform, not the recipient's — so an Android user sharing with an iPhone
  /// friend sent them to Google Play, and a recipient who already had the app
  /// was still sent to a store listing instead of into it.
  static Future<void> shareApp(BuildContext context) async {
    if (_isSharing) return;
    _isSharing = true;

    // iPad renders the share sheet as a popover and needs an anchor rect,
    // otherwise it throws. Anchor it to the widget that triggered the share.
    final box = context.findRenderObject() as RenderBox?;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '${'share.app_message'.tr()}\n${AppShareLinks.openApp}',
          subject: 'share.app_subject'.tr(),
          sharePositionOrigin: _anchorFor(box),
        ),
      );
    } finally {
      _isSharing = false;
    }
  }

  /// Shares a link to a single product.
  static Future<void> shareProduct(
    BuildContext context, {
    required String productId,
    required String productName,
  }) async {
    if (_isSharing) return;
    _isSharing = true;

    final box = context.findRenderObject() as RenderBox?;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '$productName\n${AppShareLinks.product(productId)}',
          subject: productName,
          sharePositionOrigin: _anchorFor(box),
        ),
      );
    } finally {
      _isSharing = false;
    }
  }

  /// Shares a challenge — its name plus a link to the challenges screen.
  static Future<void> shareChallenge(
    BuildContext context, {
    required String challengeName,
  }) async {
    if (_isSharing) return;
    _isSharing = true;

    final box = context.findRenderObject() as RenderBox?;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '$challengeName\n${AppShareLinks.challenges}',
          subject: challengeName,
          sharePositionOrigin: _anchorFor(box),
        ),
      );
    } finally {
      _isSharing = false;
    }
  }

  static Rect? _anchorFor(RenderBox? box) =>
      box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
}
