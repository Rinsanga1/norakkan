class Variant < ApplicationRecord
  belongs_to :product

  enum :size, { _250g: 0, _500g: 1, _1000g: 2 }
  enum :grind, { wholebean: 0, aeropress: 1, channi: 2, coffee_filter: 3, cold_brew: 4, commercial_espresso: 5, french_press: 6, home_espresso: 7, inverted_aeropress: 8, moka_pot: 9, pourover: 10, south_indian_filter: 11 }

  validates :size, presence: true
  validates :grind, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :size, uniqueness: { scope: [:product_id, :grind], message: "combination already exists for this product" }
  validates :inventory_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Check if variant is in stock
  def in_stock?
    inventory_quantity > 0
  end

  # Check if variant is out of stock
  def out_of_stock?
    inventory_quantity <= 0
  end

  # Check if variant has low stock (less than 10)
  def low_stock?
    inventory_quantity > 0 && inventory_quantity < 10
  end

  # Get stock status for display
  def stock_status
    return "out_of_stock" if out_of_stock?
    return "low_stock" if low_stock?
    "in_stock"
  end

  # Decrease inventory by quantity
  def decrease_inventory!(quantity)
    update!(inventory_quantity: [inventory_quantity - quantity, 0].max)
  end

  # Increase inventory by quantity
  def increase_inventory!(quantity)
    update!(inventory_quantity: inventory_quantity + quantity)
  end

  # Check if requested quantity is available
  def available_quantity?(requested_quantity)
    inventory_quantity >= requested_quantity
  end
end
