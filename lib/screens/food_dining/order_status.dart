class OrderStatus {

  static const pending = 'PENDING';

  static const accepted = 'ACCEPTED';

  static const preparing = 'PREPARING';

  static const ready = 'READY';

  static const riderAssigned = 'RIDER_ASSIGNED';

  static const pickedUp = 'PICKED_UP';

  static const outForDelivery = 'OUT_FOR_DELIVERY';

  static const delivered = 'DELIVERED';

  static const rejected = 'REJECTED';
}

class PaymentStatus {

  static const unpaid = 'UNPAID';

  static const pending = 'PENDING';

  static const submitted = 'SUBMITTED';

  static const verified = 'VERIFIED';

  static const paid = 'PAID';
}