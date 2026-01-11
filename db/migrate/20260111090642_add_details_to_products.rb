class AddDetailsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :roast_level, :integer
    add_column :products, :drinking_preference, :integer
    add_column :products, :flavour_profile, :integer
    add_column :products, :equipment, :integer
    add_column :products, :stock, :integer
  end
end
