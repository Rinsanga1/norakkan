class AddSkuToVariants < ActiveRecord::Migration[8.0]
  def change
    add_column :variants, :sku, :string
    add_index :variants, :sku, unique: true
  end
end
