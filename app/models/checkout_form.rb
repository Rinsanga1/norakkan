class CheckoutForm
  include ActiveModel::Model

  attr_accessor :name, :phone, :address_line_1, :address_line_2, :city, :state, :postal_code, :country, :notes, :save_address, :address_label, :use_saved_address, :shipping_address_id
end
