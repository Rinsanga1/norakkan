class CartItem < ApplicationRecord
  belongs_to :variant, optional: true
  belongs_to :product, optional: true
  belongs_to :cart

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :check_inventory_availability

  def price
    variant ? variant.price : product.price
  end

  def product_name
    variant ? variant.product.name : product.name
  end

  def in_stock?
    if variant
      variant.in_stock? && variant.available_quantity?(quantity)
    else
      product.in_stock? && product.inventory_quantity >= quantity
    end
  end

  private

  def check_inventory_availability
    if variant
      unless variant.available_quantity?(quantity)
        errors.add(:quantity, "Only #{variant.inventory_quantity} available in stock")
      end
    elsif product
      unless product.inventory_quantity >= quantity
        errors.add(:quantity, "Only #{product.inventory_quantity} available in stock")
      end
    end
  end
end
