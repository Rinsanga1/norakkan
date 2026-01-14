class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true
  belongs_to :variant, optional: true

  validates :order, :quantity, :price, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  before_create :calculate_subtotal

  def calculate_subtotal
    self.subtotal = price * quantity
  end
end
