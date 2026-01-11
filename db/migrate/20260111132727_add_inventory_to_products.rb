class AddInventoryToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :inventory_quantity, :integer, default: 0, null: false
    add_index :products, :inventory_quantity
  end
end
