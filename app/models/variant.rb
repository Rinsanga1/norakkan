class Variant < ApplicationRecord
  belongs_to :product

  enum :size, { _250g: 0, _500g: 1, _1000g: 2 }
  enum :grind, { wholebean: 0, aeropress: 1, channi: 2, coffee_filter: 3, cold_brew: 4, commercial_espresso: 5, french_press: 6, home_espresso: 7, inverted_aeropress: 8, moka_pot: 9, pourover: 10, south_indian_filter: 11 }

  validates :size, presence: true
  validates :grind, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :size, uniqueness: { scope: [ :product_id, :grind ], message: "combination already exists for this product" }
  validates :inventory_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, uniqueness: true, allow_nil: true

  before_validation :normalize_sku, if: -> { sku.present? }
  after_create :generate_sku, if: -> { sku.blank? }

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
    update!(inventory_quantity: [ inventory_quantity - quantity, 0 ].max)
  end

  # Increase inventory by quantity
  def increase_inventory!(quantity)
    update!(inventory_quantity: inventory_quantity + quantity)
  end

  # Check if requested quantity is available
  def available_quantity?(requested_quantity)
    inventory_quantity >= requested_quantity
  end

  private

  # Generate SKU automatically based on product and variant attributes
  def generate_sku
    return if product.nil?

    product_name_clean = product.name.to_s.gsub(/[^a-zA-Z0-9]/, "").upcase
    product_code = product_name_clean[0..3] || "PRD"

    size_code = case size
    when "_250g" then "250"
    when "_500g" then "500"
    when "_1000g" then "1KG"
    else "SZE"
    end

    grind_code = grind.to_s.gsub("_", "").upcase[0..3] || "GRN"
    base_sku = "#{product_code}-#{size_code}-#{grind_code}"
    generated_sku = "#{base_sku}-#{id.to_s.rjust(3, '0')}"

    if Variant.where(sku: generated_sku).where.not(id: id).exists?
      generated_sku = "#{base_sku}-#{id.to_s.rjust(3, '0')}-#{SecureRandom.hex(2).upcase}"
    end

    update_column(:sku, generated_sku)
  end

  # Normalize SKU
  def normalize_sku
    return if sku.blank?
    self.sku = sku.to_s.upcase.strip.gsub(/\s+/, "-").gsub(/[^a-zA-Z0-9\-]/, "")
  end
end
