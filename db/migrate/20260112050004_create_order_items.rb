class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true, index: true
      t.references :product, foreign_key: true, index: true
      t.references :variant, foreign_key: true, index: true
      t.string :product_name, null: false
      t.string :variant_info
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :quantity, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
