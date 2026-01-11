class Product < ApplicationRecord
  has_many :variants, dependent: :destroy
  accepts_nested_attributes_for :variants,
    allow_destroy: true,
    reject_if: ->(attrs) { attrs['size'].blank? || attrs['grind'].blank? || attrs['price'].blank? }

  enum :roast_level, { dark: 0, light: 1, medium: 2, medium_dark: 3 }
  enum :drinking_preference, { with_milk: 0, with_or_without_milk: 1, without_milk: 2 }
  enum :flavour_profile, { balanced: 0, bold_and_bitter: 1, chocolatey_and_nutty: 2,
                          experimental: 3, fresh_and_flavourful: 4, fruity_and_punchy: 5 }
  enum :equipment, { aeropress: 0, channi: 1, cold_brew: 2, espresso: 3, french_press: 4,
                    inverted_aeropress: 5, moka_pot: 6, pourover: 7, south_indian_filter: 8 }

  validates :price, presence: true, numericality: { greater_than: 0 }, if: -> { variants.empty? }
  validates :inventory_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { variants.empty? }
  validates :sku, uniqueness: true, allow_nil: true
  validate :has_price_or_variants

  before_validation :normalize_sku, if: -> { sku.present? }
  after_create :generate_sku, if: -> { sku.blank? && variants.empty? }

  # Get price - either from first variant or product's own price
  def price
    if variants.any?
      variants.first.price
    else
      read_attribute(:price)
    end
  end

  # Check if product has variants
  def has_variants?
    variants.any?
  end

  # Check if product is in stock (for simple products)
  def in_stock?
    return variants.any?(&:in_stock?) if has_variants?
    inventory_quantity > 0
  end

  # Check if product is out of stock
  def out_of_stock?
    return variants.all?(&:out_of_stock?) if has_variants?
    inventory_quantity <= 0
  end

  # Get available variant combinations for display
  def available_combinations
    variants.pluck(:size, :grind).uniq.map { |size, grind| "#{size.humanize} / #{grind.humanize}" }
  end

  # Get total inventory across all variants
  def total_inventory
    return inventory_quantity unless has_variants?
    variants.sum(:inventory_quantity)
  end

  private

  def has_price_or_variants
    if variants.empty? && price.nil?
      errors.add(:base, "Product must have either variants or a direct price")
    end
  end

  # Generate SKU for simple products (without variants)
  def generate_sku
    return if variants.any? # Only generate for simple products

    product_name_clean = name.to_s.gsub(/[^a-zA-Z0-9]/, '').upcase
    product_code = product_name_clean[0..3] || "PRD"

    generated_sku = "#{product_code}-#{id.to_s.rjust(4, '0')}"

    # Check if SKU already exists
    if Product.where(sku: generated_sku).where.not(id: id).exists?
      generated_sku = "#{product_code}-#{id.to_s.rjust(4, '0')}-#{SecureRandom.hex(2).upcase}"
    end

    update_column(:sku, generated_sku)
  end

  # Normalize SKU
  def normalize_sku
    return if sku.blank?
    self.sku = sku.to_s.upcase.strip.gsub(/\s+/, '-').gsub(/[^a-zA-Z0-9\-]/, '')
  end
end
