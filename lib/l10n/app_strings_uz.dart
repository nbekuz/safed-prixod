import 'package:safed_prixod/l10n/app_strings.dart';

class AppStringsUz extends AppStrings {
  @override
  String get appSubtitle => "Ombor — yig'ish (prixod)";

  @override
  String get phone => 'Telefon';

  @override
  String get sendCode => 'Kod yuborish';

  @override
  String get signIn => 'Kirish';

  @override
  String get enterPhone => 'Telefon raqamini kiriting';

  @override
  String get phoneInvalid => "To'liq raqam kiriting: (99)-123-45-67";

  @override
  String get staffOnly => 'Operator yoki admin kirishi kerak';

  @override
  String get loginSuccess => 'Prixod';

  @override
  String get otpHint => 'SMS kodini kiriting';

  @override
  String get changePhone => 'Raqamni o\'zgartirish';

  @override
  String get resendCode => 'Kodni qayta yuborish';

  @override
  String resendIn(int seconds) => 'Qayta yuborish: $seconds s';

  @override
  String get wrongCode => 'Kod noto\'g\'ri';

  @override
  String get activeOrdersTitle => 'Faol buyurtmalar';

  @override
  String get noActiveOrders => 'Faol buyurtma yo\'q';

  @override
  String get deliverBy => 'Yetkazish';

  @override
  String orderDetailTitle(int orderId) => 'Buyurtma #$orderId';

  @override
  String get statusLabel => 'Holat';

  @override
  String statusDisplayName(String status) => switch (status) {
    'created' => 'Yangi',
    'confirmed' => 'Tasdiqlangan',
    'picking' => 'Yig\'ilmoqda',
    'shipped' => 'Jo\'natilgan',
    'delivered' => 'Yetkazilgan',
    'completed' => 'Yakunlangan',
    'rejected' => 'Rad etilgan',
    'cancelled' => 'Bekor qilingan',
    _ => status,
  };

  @override
  String get customerLabel => 'Mijoz';

  @override
  String get addressLabel => 'Manzil';

  @override
  String get deliveryTimeLabel => 'Yetkazish vaqti';

  @override
  String get paymentLabel => 'To\'lov';

  @override
  String paymentTypeLabel(String type) => switch (type) {
    'cash' => 'Naqd',
    'card' => 'Karta',
    _ => type,
  };

  @override
  String get commentLabel => 'Izoh';

  @override
  String get productsSection => 'Mahsulotlar';

  @override
  String get shelfLabel => 'Tokcha';

  @override
  String get shelfNotSet => 'Belgilanmagan';

  @override
  String orderQuantityLine(String ordered, String current) =>
      'Buyurtma: $ordered · Miqdor: $current';

  @override
  String piecesCount(String count) => '$count dona';

  @override
  String get unitPieceLabel => 'dona';

  @override
  String get quantity => 'Miqdor';

  @override
  String get enterValidQuantity => 'To\'g\'ri miqdor kiriting';

  @override
  String get saveQuantity => 'Saqlash';

  @override
  String scanned(String barcode) => 'Skanerlandi: $barcode';

  @override
  String get quantityUpdated => 'Miqdor yangilandi';

  @override
  String statusChanged(String status) => 'Holat: ${statusDisplayName(status)}';

  @override
  String get actionConfirmOrder => 'Buyurtmani tasdiqlash';

  @override
  String get actionStartPicking => 'Yig\'ishni boshlash';

  @override
  String get actionMarkShipped => 'Yig\'ish tugadi — jo\'natildi';

  @override
  String checkProductsTitle(int orderId) => 'Tekshiruv #$orderId';

  @override
  String get scanButton => 'Skaner';

  @override
  String get exitScanner => 'Chiqish';

  @override
  String get scanPageHint =>
      'Mahsulot shtrix-kodini ramka ichiga joylashtiring';

  @override
  String get cameraPermissionRequired =>
      'Shtrix-kod skanerlash uchun kameraga ruxsat kerak';

  @override
  String get cameraPermissionDenied =>
      'Kamera ruxsati berilmadi. Sozlamalardan yoqing';

  @override
  String get openAppSettings => 'Sozlamalar';

  @override
  String get tryAgain => 'Qayta urinish';

  @override
  String barcodeNotInOrder(String barcode) =>
      'Bu shtrix-kod buyurtmada yo\'q: $barcode';

  @override
  String get barcodeAlreadyScanned => 'Bu mahsulot allaqachon skanerlangan';

  @override
  String get finishPicking => 'Yig\'ishni yakunlash';

  @override
  String get confirmFinishPicking =>
      'Barcha mahsulotlar skanerlandi. Yig\'ishni yakunlaysizmi?';

  @override
  String get selectCourier => 'Kuryerni tanlang';

  @override
  String get assignCourier => 'Kuryer biriktirish';

  @override
  String get noCouriers => 'Kuryer topilmadi';

  @override
  String get productNotInOrder => 'Buyurtmada yo\'q';

  @override
  String packSizePerUnit(String size) => 'Qadoq: $size';

  @override
  String scannedProgress(int done, int total) => 'Skaner: $done / $total';

  @override
  String get actionRejectOrder => 'Rad etish';

  @override
  String get actionCancelOrder => 'Bekor qilish';

  @override
  String get orLabel => 'yoki';

  @override
  String confirmStatusChange(String actionLabel) => '$actionLabel?';

  @override
  String get dialogNo => 'Yo\'q';

  @override
  String get dialogYes => 'Ha';

  @override
  String get totalLabel => 'Summa';

  @override
  String orderPrice(String amount) => '$amount so\'m';

  @override
  String productFallback(int productId) => 'Mahsulot #$productId';
}
