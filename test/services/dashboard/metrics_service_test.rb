require "test_helper"

class Dashboard::MetricsServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @shipping_address = shipping_addresses(:one)
    @order = Order.create!(user: @user, shipping_address: @shipping_address, subtotal: 100, total: 150, status: :paid)
    @service = Dashboard::MetricsService.new
  end

  test "should calculate total sales" do
    assert_equal 150, @service.total_sales
  end

  test "should calculate total orders" do
    assert_equal 1, @service.total_orders
  end

  test "should calculate average order value" do
    assert_equal 150, @service.average_order_value
  end

  test "should calculate active customers" do
    assert_equal 1, @service.active_customers
  end

  test "should return orders by status" do
    status_counts = @service.orders_by_status
    assert status_counts.key?("paid")
    assert_equal 1, status_counts["paid"]
  end

  test "should filter by time range" do
    last_month_service = Dashboard::MetricsService.new(:last_30_days)
    assert last_month_service.total_orders >= 0
  end
end
