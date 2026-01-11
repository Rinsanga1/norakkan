class CreateVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :variants do |t|
      t.belongs_to :product, null: false, foreign_key: true
      t.integer :size
      t.integer :grind
      t.decimal :price

      t.timestamps
    end
  end
end
