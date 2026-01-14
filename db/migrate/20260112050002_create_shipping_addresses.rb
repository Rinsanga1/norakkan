class CreateShippingAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :shipping_addresses do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :label, default: "Home"
      t.string :name, null: false
      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city, null: false
      t.string :state, null: false
      t.string :postal_code, null: false
      t.string :country, default: "India"
      t.string :phone
      t.boolean :default, default: false
      t.timestamps
    end
  end
end
