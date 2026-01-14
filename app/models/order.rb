class Order < ApplicationRecord
  belongs_to :user
  belongs_to :shipping_address
  has_many :order_items, dependent: :destroy

  enum :status, { pending: 0, paid: 1, processing: 2, shipped: 3, delivered: 4, cancelled: 5 }
  enum :payment_status, { unpaid: 0, completed: 1, failed: 2, refunded: 3 }

  validates :user, :total, :subtotal, presence: true
  validates :shipping_address, presence: true, on: :update
  validates :status, :payment_status, presence: true

  before_create :calculate_totals

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_webhook, ->(razorpay_order_id) { find_by(razorpay_order_id: razorpay_order_id) }

  def calculate_totals
    self.shipping_cost = calculate_shipping
    self.total = subtotal + shipping_cost
  end

  def display_order_number
    "ORD-#{id.to_s.rjust(5, '0')}"
  end

  def shipping_free?
    subtotal >= 500
  end

  def calculate_shipping
    shipping_free? ? 0 : 50
  end

  def display_shipping_address
    return nil unless shipping_address
    {
      name: shipping_address.name,
      address_line_1: shipping_address.address_line_1,
      address_line_2: shipping_address.address_line_2,
      city: shipping_address.city,
      state: shipping_address.state,
      postal_code: shipping_address.postal_code,
      country: shipping_address.country,
      phone: shipping_address.phone
    }
  end
end
