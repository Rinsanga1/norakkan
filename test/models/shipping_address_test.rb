require "test_helper"

class ShippingAddressTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid Indian phone with +91 prefix and spaces" do
    address = ShippingAddress.new(
      user: @user,
      label: "Home",
      name: "Test User",
      address_line_1: "123 Street",
      city: "Mumbai",
      state: "Maharashtra",
      postal_code: "400001",
      phone: "+91 98765 43210",
      country: "India"
    )
    assert address.valid?
  end

  test "valid Indian phone with 0 prefix" do
    address = ShippingAddress.new(
      user: @user,
      label: "Home",
      name: "Test User",
      address_line_1: "123 Street",
      city: "Mumbai",
      state: "Maharashtra",
      postal_code: "400001",
      phone: "09876543210",
      country: "India"
    )
    assert address.valid?
  end

  test "normalizes phone by removing non-digits" do
    address = ShippingAddress.new(
      user: @user,
      label: "Home",
      name: "Test User",
      address_line_1: "123 Street",
      city: "Mumbai",
      state: "Maharashtra",
      postal_code: "400001",
      phone: "+91 98765-43210",
      country: "India"
    )
    assert address.valid?
    assert_equal "919876543210", address.phone
  end

  test "invalid Indian phone starting with wrong prefix" do
    address = ShippingAddress.new(
      user: @user,
      label: "Home",
      name: "Test User",
      address_line_1: "123 Street",
      city: "Mumbai",
      state: "Maharashtra",
      postal_code: "400001",
      phone: "11234567890",
      country: "India"
    )
    assert_not address.valid?
    assert_includes address.errors[:phone], "must be a valid Indian phone number (e.g., +91 9876543210 or 09876543210)"
  end
end
