import 'package:safed_prixod/l10n/app_strings.dart';

class AppStringsRu extends AppStrings {
  @override
  String get appSubtitle => 'Склад — комплектация (приход)';

  @override
  String get phone => 'Телефон';

  @override
  String get sendCode => 'Отправить код';

  @override
  String get signIn => 'Войти';

  @override
  String get enterPhone => 'Введите номер телефона';

  @override
  String get phoneInvalid => 'Введите полный номер: (99)-123-45-67';

  @override
  String get staffOnly => 'Требуется вход оператора или администратора';

  @override
  String get loginSuccess => 'Приход';

  @override
  String get otpHint => 'Введите код из SMS';

  @override
  String get changePhone => 'Изменить номер';

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String resendIn(int seconds) => 'Повторно через: $seconds с';

  @override
  String get wrongCode => 'Неверный код';

  @override
  String get activeOrdersTitle => 'Активные заказы';

  @override
  String get noActiveOrders => 'Нет активных заказов';

  @override
  String get deliverBy => 'Доставка';

  @override
  String orderDetailTitle(int orderId) => 'Заказ #$orderId';

  @override
  String get statusLabel => 'Статус';

  @override
  String statusDisplayName(String status) => switch (status) {
    'created' => 'Создан',
    'confirmed' => 'Подтверждён',
    'picking' => 'Комплектация',
    'shipped' => 'Отправлен',
    'delivered' => 'Доставлен',
    'completed' => 'Завершён',
    'rejected' => 'Отклонён',
    'cancelled' => 'Отменён',
    _ => status,
  };

  @override
  String get customerLabel => 'Клиент';

  @override
  String get addressLabel => 'Адрес';

  @override
  String get deliveryTimeLabel => 'Время доставки';

  @override
  String get paymentLabel => 'Оплата';

  @override
  String paymentTypeLabel(String type) => switch (type) {
    'cash' => 'Наличные',
    'card' => 'Карта',
    _ => type,
  };

  @override
  String get commentLabel => 'Комментарий';

  @override
  String get productsSection => 'Товары';

  @override
  String get shelfLabel => 'Полка';

  @override
  String get shelfNotSet => 'Не указана';

  @override
  String orderQuantityLine(String ordered, String current) =>
      'Заказано: $ordered · Кол-во: $current';

  @override
  String piecesCount(String count) => '$count шт';

  @override
  String get unitPieceLabel => 'шт';

  @override
  String get quantity => 'Количество';

  @override
  String get enterValidQuantity => 'Введите корректное количество';

  @override
  String get saveQuantity => 'Сохранить';

  @override
  String scanned(String barcode) => 'Отсканировано: $barcode';

  @override
  String get quantityUpdated => 'Количество обновлено';

  @override
  String statusChanged(String status) => 'Статус: ${statusDisplayName(status)}';

  @override
  String get actionConfirmOrder => 'Подтвердить заказ';

  @override
  String get actionStartPicking => 'Начать комплектацию';

  @override
  String get actionMarkShipped => 'Комплектация завершена — отправить';

  @override
  String checkProductsTitle(int orderId) => 'Проверка #$orderId';

  @override
  String get scanButton => 'Сканер';

  @override
  String get exitScanner => 'Выйти';

  @override
  String get scanPageHint => 'Наведите штрих-код товара в рамку';

  @override
  String get cameraPermissionRequired =>
      'Для сканирования нужен доступ к камере';

  @override
  String get cameraPermissionDenied =>
      'Нет доступа к камере. Включите в настройках';

  @override
  String get openAppSettings => 'Настройки';

  @override
  String get tryAgain => 'Повторить';

  @override
  String barcodeNotInOrder(String barcode) => 'Штрих-код не в заказе: $barcode';

  @override
  String get barcodeAlreadyScanned => 'Этот товар уже отсканирован';

  @override
  String get finishPicking => 'Завершить комплектацию';

  @override
  String get confirmFinishPicking =>
      'Все товары отсканированы. Завершить комплектацию?';

  @override
  String get selectCourier => 'Выберите курьера';

  @override
  String get assignCourier => 'Назначить курьера';

  @override
  String get noCouriers => 'Курьеры не найдены';

  @override
  String get productNotInOrder => 'Нет в заказе';

  @override
  String packSizePerUnit(String size) => 'Упаковка: $size';

  @override
  String scannedProgress(int done, int total) => 'Скан: $done / $total';

  @override
  String get actionRejectOrder => 'Отклонить';

  @override
  String get actionCancelOrder => 'Отменить';

  @override
  String get orLabel => 'или';

  @override
  String confirmStatusChange(String actionLabel) => '$actionLabel?';

  @override
  String get dialogNo => 'Нет';

  @override
  String get dialogYes => 'Да';

  @override
  String get totalLabel => 'Сумма';

  @override
  String orderPrice(String amount) => '$amount сум';

  @override
  String productFallback(int productId) => 'Товар #$productId';
}
