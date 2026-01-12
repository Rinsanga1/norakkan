# Set default currency to Indian Rupees
Rails.application.configure do
  config.i18n.default_locale = :en
  config.i18n.available_locales = [ :en ]

  # Set default currency to INR (Indian Rupees)
  config.after_initialize do
    Money.default_currency = Money::Currency.new("INR")
  end
end
