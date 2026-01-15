class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :shipping_addresses, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :full_name, :phone, presence: true, on: :update, if: :require_profile_complete?

  scope :admin, -> { where(admin: true) }
  scope :with_orders, -> { joins(:orders).distinct }
  scope :by_spending, -> { joins(:orders).group("users.id").select("users.*, SUM(orders.total) as total_spent").order("total_spent DESC") }

  def name
    full_name || email_address.split("@").first
  end

  def default_shipping_address
    shipping_addresses.default.first
  end

  def total_spent
    orders.where(payment_status: :paid).sum(:total)
  end

  def order_count
    orders.count
  end

  def average_order_value
    return 0 if order_count.zero?
    total_spent / order_count
  end

  private

  def require_profile_complete?
    false
  end
end
