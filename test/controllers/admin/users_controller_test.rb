require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get users index" do
    get admin_users_path
    assert_response :success
  end

  test "should search users" do
    get admin_users_path(search: @user.email_address)
    assert_response :success
  end

  test "should sort users" do
    get admin_users_path(sort_by: "created_at", sort_direction: "desc")
    assert_response :success
  end

  test "should show user" do
    get admin_user_path(@user)
    assert_response :success
  end

  test "should export users as CSV" do
    get export_admin_users_path
    assert_response :success
    assert_equal "text/csv", response.content_type
  end
end
