require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get dashboard index" do
    get admin_root_path
    assert_response :success
  end

  test "should return dashboard data as JSON" do
    get admin_root_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("total_sales")
    assert json_response.key?("total_orders")
    assert json_response.key?("average_order_value")
    assert json_response.key?("active_customers")
    assert json_response.key?("orders_by_status")
    assert json_response.key?("sales_by_date")
  end

  test "should filter by time range" do
    get admin_root_path(time_range: "last_7_days")
    assert_response :success
  end

  test "should get analytics page" do
    get admin_analytics_path
    assert_response :success
  end
end
