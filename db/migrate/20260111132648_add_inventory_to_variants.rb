class AddInventoryToVariants < ActiveRecord::Migration[8.0]
  def change
    add_column :variants, :inventory_quantity, :integer, default: 0, null: false
    add_index :variants, :inventory_quantity
  end
end
