class Product < ApplicationRecord
  has_many :variants, dependent: :destroy
  accepts_nested_attributes_for :variants, allow_destroy: true

  enum :roast_level, { dark: 0, light: 1, medium: 2, medium_dark: 3 }

  enum :drinking_preference, { with_milk: 0, with_or_without_milk: 1, without_milk: 2 }

  enum :flavour_profile, { balanced: 0, bold_and_bitter: 1, chocolatey_and_nutty: 2, experimental: 3, fresh_and_flavourful: 4, fruity_and_punchy: 5 }

  enum :equipment, { aeropress: 0, channi: 1, cold_brew: 2, espresso: 3, french_press: 4, inverted_aeropress: 5, moka_pot: 6, pourover: 7, south_indian_filter: 8 }

  # Get price - either from first variant or product's own price
  def price
    if variants.any?
      variants.first.price
    else
      read_attribute(:price) # Use product's price column
    end
  end

  # Check if product has variants
  def has_variants?
    variants.any?
  end
end
