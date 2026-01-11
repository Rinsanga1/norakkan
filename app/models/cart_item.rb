class CartItem < ApplicationRecord
  belongs_to :variant, optional: true
  belongs_to :product, optional: true
  belongs_to :cart

  def price
    variant ? variant.price : product.price
  end

  def product_name
    variant ? variant.product.name : product.name
  end
end
