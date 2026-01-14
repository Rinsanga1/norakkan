class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true, index: true

      # Order status
      t.integer :status, default: 0, null: false
      t.integer :payment_status, default: 0, null: false

      # Pricing
      t.decimal :subtotal, precision: 10, scale: 2, null: false
      t.decimal :shipping_cost, precision: 10, scale: 2, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false

      # Razorpay fields
      t.string :razorpay_order_id
      t.string :razorpay_payment_id
      t.string :razorpay_signature

      # Shipping address reference
      t.references :shipping_address, foreign_key: true, index: true

      # Customer notes
      t.text :notes

      t.timestamps
    end
  end
end
