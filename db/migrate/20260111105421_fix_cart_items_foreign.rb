class FixCartItemsForeign < ActiveRecord::Migration[8.0]
 def change
   # Remove the incorrect foreign key
   remove_foreign_key :cart_items, :products

   # Add the correct foreign key
   add_foreign_key :cart_items, :variants
 end
end
