class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :shipping_addresses, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :full_name, :phone, presence: true, on: :update, if: :require_profile_complete?

  scope :admin, -> { where(admin: true) }

  def name
    full_name || email_address.split("@").first
  end

  def default_shipping_address
    shipping_addresses.default.first
  end

  private

  def require_profile_complete?
    false
  end
end
