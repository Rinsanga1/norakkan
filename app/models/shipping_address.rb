class ShippingAddress < ApplicationRecord
  belongs_to :user

  validates :user, :label, :name, :address_line_1, :city, :state, :postal_code,
            presence: true

  before_validation :normalize_phone

  def normalize_phone
    return unless phone.present?

    normalized = phone.to_s.gsub(/\D/, "")

    if normalized.start_with?("91") && normalized.length == 12
      normalized = normalized[2..-1]
    elsif normalized.start_with?("0") && normalized.length == 11
      normalized = normalized[1..-1]
    end

    self.phone = normalized
  end

  validates :phone, presence: true, format: {
    with: /\A(?:\+91|0)?[6789]\d{9}\z/,
    message: "must be a valid Indian phone number (e.g., +91 9876543210 or 09876543210)"
  }

  scope :for_user, ->(user) { where(user: user) }
  scope :default, -> { where(default: true) }
  scope :recent, -> { order(updated_at: :desc) }

  def formatted
    [
      name,
      address_line_1,
      address_line_2,
      city,
      state,
      postal_code,
      country
    ].compact.join(", ")
  end

  def set_as_default!
    user.shipping_addresses.update_all(default: false)
    update!(default: true)
  end
end
