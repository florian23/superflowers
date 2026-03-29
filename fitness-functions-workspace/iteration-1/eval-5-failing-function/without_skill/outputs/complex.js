function getHeavyInternationalExpress(order) {
  if (order.insurance && order.fragile) {
    return 'special-handling';
  }
  return order.insurance ? 'international-express-insured' : 'international-express';
}

function getExpressShipping(order) {
  if (order.weight <= 10) {
    return 'standard-express';
  }
  if (order.destination === 'international') {
    return getHeavyInternationalExpress(order);
  }
  return 'domestic-heavy-express';
}

function processOrder(order) {
  if (order.type === 'express') {
    return getExpressShipping(order);
  }
  return order.weight > 20 ? 'freight' : 'standard';
}

module.exports = { processOrder };
