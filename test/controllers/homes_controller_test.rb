require 'test_helper'

class HomesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_0 = users(:user_0)
  end

  test "should get dashboard" do
    sign_in @user_0
    get homes_dashboard_url
    assert_response :success
  end

  test "should redirect to login page if not logged in" do
    get homes_dashboard_url
    assert_redirected_to new_user_session_path, "User is not redirected!"
  end

  test "should redirect to root page if logged in but tried to render login page" do
    sign_in @user_0
    get new_user_session_path
    assert_redirected_to root_path, "User is not redirected!"
    assert_equal "You are already signed in.", flash[:notice]
  end

  test "should render login page" do
    get new_user_session_path
    assert_response :success
  end
end
