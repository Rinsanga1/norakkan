class AllowNullVariantIdInCartItems < ActiveRecord::Migration[8.0]
  def change
    change_column_null :cart_items, :variant_id, true
  end
end
