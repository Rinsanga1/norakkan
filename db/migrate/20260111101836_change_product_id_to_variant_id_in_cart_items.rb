class ChangeProductIdToVariantIdInCartItems < ActiveRecord::Migration[8.0]
  def change
    rename_column :cart_items, :product_id, :variant_id
  end
end
