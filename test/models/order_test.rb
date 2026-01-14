require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @shipping_address = shipping_addresses(:one)
    @order = Order.new(user: @user, shipping_address: @shipping_address, subtotal: 100, total: 150)
  end

  test "order is valid with required attributes" do
    assert @order.valid?
  end

  test "order is invalid without user" do
    @order.user = nil
    assert_not @order.valid?
    assert_includes @order.errors[:user], "can't be blank"
  end

  test "order is invalid without subtotal" do
    @order.subtotal = nil
    assert_not @order.valid?
    assert_includes @order.errors[:subtotal], "can't be blank"
  end

  test "order is invalid without total" do
    @order.total = nil
    assert_not @order.valid?
    assert_includes @order.errors[:total], "can't be blank"
  end

  test "order can be created without shipping_address initially" do
    order = Order.new(user: @user, subtotal: 100, total: 150)
    assert order.valid?
  end

  test "order requires shipping_address on update" do
    order = Order.create!(user: @user, subtotal: 100, total: 150)
    order.status = :paid
    assert_not order.valid?
    assert_includes @order.errors[:shipping_address], "can't be blank"

    order.shipping_address = @shipping_address
    assert order.valid?
  end

  test "display_order_number returns formatted string" do
    order = Order.create!(id: 123, user: @user, shipping_address: @shipping_address, subtotal: 100, total: 150)
    assert_equal "ORD-00123", order.display_order_number
  end

  test "calculate_shipping returns 0 for orders over 500" do
    order = Order.new(user: @user, shipping_address: @shipping_address, subtotal: 600)
    assert_equal 0, order.calculate_shipping
  end

  test "calculate_shipping returns 50 for orders under 500" do
    order = Order.new(user: @user, shipping_address: @shipping_address, subtotal: 400)
    assert_equal 50, order.calculate_shipping
  end

  test "shipping_free? returns true for orders over 500" do
    order = Order.new(user: @user, shipping_address: @shipping_address, subtotal: 600)
    assert order.shipping_free?
  end

  test "shipping_free? returns false for orders under 500" do
    order = Order.new(user: @user, shipping_address: @shipping_address, subtotal: 400)
    assert_not order.shipping_free?
  end

  test "calculate_totals updates shipping and total" do
    order = Order.new(user: @user, shipping_address: @shipping_address, subtotal: 400)
    order.calculate_totals
    assert_equal 50, order.shipping_cost
    assert_equal 450, order.total
  end
end

  test "payment_status enum values are correctly defined" do
    order = Order.create!(user: @user, shipping_address: @shipping_address, subtotal: 100, total: 150)
    
    assert_equal 0, Order.payment_statuses[:unpaid]
    assert_equal 1, Order.payment_statuses[:paid]
    assert_equal 2, Order.payment_statuses[:failed]
    assert_equal 3, Order.payment_statuses[:refunded]
  end

  test "order defaults to unpaid payment_status" do
    order = Order.new(user: @user, subtotal: 100, total: 150)
    assert_equal :unpaid, order.payment_status
  end

  test "can set payment_status to paid" do
    order = Order.create!(user: @user, shipping_address: @shipping_address, subtotal: 100, total: 150)
    order.update!(payment_status: :paid)
    assert_equal :paid, order.payment_status
  end
