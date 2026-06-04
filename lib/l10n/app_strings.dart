import 'package:safed_prixod/l10n/app_locale.dart';
import 'package:safed_prixod/l10n/app_strings_ru.dart';
import 'package:safed_prixod/l10n/app_strings_uz.dart';

/// All user-visible strings. Add a key here, then implement in uz/ru files.
abstract class AppStrings {
  String get appSubtitle;
  String get phone;
  String get sendCode;
  String get signIn;
  String get enterPhone;
  String get phoneInvalid;
  String get staffOnly;
  String get loginSuccess;
  String get otpHint;
  String get changePhone;
  String get resendCode;
  String resendIn(int seconds);
  String get wrongCode;

  String get activeOrdersTitle;
  String get noActiveOrders;
  String get deliverBy;

  String orderDetailTitle(int orderId);
  String get statusLabel;
  String statusDisplayName(String status);
  String get customerLabel;
  String get addressLabel;
  String get deliveryTimeLabel;
  String get paymentLabel;
  String paymentTypeLabel(String type);
  String get commentLabel;
  String get productsSection;
  String get shelfLabel;
  String get shelfNotSet;
  String orderQuantityLine(String ordered, String current);
  String piecesCount(String count);
  String get unitPieceLabel;
  String get quantity;
  String get enterValidQuantity;
  String get saveQuantity;
  String scanned(String barcode);
  String get quantityUpdated;
  String statusChanged(String status);
  String get actionConfirmOrder;
  String get actionStartPicking;
  String get actionMarkShipped;
  String checkProductsTitle(int orderId);
  String get scanButton;
  String get exitScanner;
  String get scanPageHint;
  String get cameraPermissionRequired;
  String get cameraPermissionDenied;
  String get openAppSettings;
  String get tryAgain;
  String barcodeNotInOrder(String barcode);
  String get barcodeAlreadyScanned;
  String get finishPicking;
  String get confirmFinishPicking;
  String get selectCourier;
  String get assignCourier;
  String get noCouriers;
  String get productNotInOrder;
  String packSizePerUnit(String size);
  String scannedProgress(int done, int total);
  String get actionRejectOrder;
  String get actionCancelOrder;
  String get orLabel;
  String confirmStatusChange(String actionLabel);
  String get dialogNo;
  String get dialogYes;
  String get totalLabel;
  String orderPrice(String amount);
  String productFallback(int productId);

  static AppStrings of(AppLocale locale) {
    switch (locale) {
      case AppLocale.ru:
        return AppStringsRu();
      case AppLocale.uz:
        return AppStringsUz();
    }
  }
}
