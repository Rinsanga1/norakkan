class Variant < ApplicationRecord
  belongs_to :product

  enum :size, { _250g: 0, _500g: 1, _1000g: 2 }

  enum :grind, { wholebean: 0, aeropress: 1, channi: 2, coffee_filter: 3, cold_brew: 4, commercial_espresso: 5, french_press: 6, home_espresso: 7, inverted_aeropress: 8, moka_pot: 9, pourover: 10, south_indian_filter: 11 }
end
