class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :variants, through: :cart_items

  def total
    cart_items.reduce(0) { |sum, item| sum + (item.price * item.quantity) }
  end
end
