require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @shipping_address = shipping_addresses(:one)
    @order = Order.create!(user: @user, shipping_address: @shipping_address, subtotal: 100, total: 150)
    sign_in_as(@user)
  end

  test "should get orders index" do
    get admin_orders_path
    assert_response :success
  end

  test "should filter orders by status" do
    get admin_orders_path(status: "pending")
    assert_response :success
  end

  test "should search orders" do
    get admin_orders_path(search: @user.email_address)
    assert_response :success
  end

  test "should show order" do
    get admin_order_path(@order)
    assert_response :success
  end

  test "should update order status" do
    patch admin_order_path(@order), params: { order: { status: "paid" } }
    assert_redirected_to admin_order_path(@order)
    @order.reload
    assert_equal "paid", @order.status
  end

  test "should export orders as CSV" do
    get export_admin_orders_path
    assert_response :success
    assert_equal "text/csv", response.content_type
  end
end
