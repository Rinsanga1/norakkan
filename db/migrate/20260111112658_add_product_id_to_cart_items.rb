class AddProductIdToCartItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :cart_items, :product, null: true, foreign_key: true
  end
end
