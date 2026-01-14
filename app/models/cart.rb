class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :variants, through: :cart_items

  def total
    cart_items.reduce(0) { |sum, item| sum + (item.price * item.quantity) }
  end

  def item_count
    cart_items.sum(:quantity)
  end

  def create_order_from_cart(user)
    raise ArgumentError, "user must be a User instance, got #{user.class}" unless user.is_a?(User)

    order = Order.new(
      user: user,
      status: :pending,
      payment_status: :unpaid
    )

    cart_items.each do |cart_item|
      order.order_items.build(
        product: cart_item.product,
        variant: cart_item.variant,
        product_name: cart_item.product_name,
        variant_info: cart_item.variant ? "#{cart_item.variant.size.humanize} / #{cart_item.variant.grind.humanize}" : nil,
        price: cart_item.price,
        quantity: cart_item.quantity
      )
    end

    order.subtotal = total
    order.calculate_totals
    order
  end
end
