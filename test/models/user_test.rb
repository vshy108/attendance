require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user_0 = users(:user_0)
    password = Faker::Internet.password
    @email = Faker::Internet.unique.email.upcase
    @username = Faker::Internet.unique.username.upcase
    @existed_email_hash =
      {
        email: @user_0.email,
        username: @username,
        name: Faker::Name.unique.name,
        password: password,
        password_confirmation: password
      }
    @existed_username_hash = {
      email: @email,
      username: @user_0.username,
      name: Faker::Name.unique.name,
      password: password,
      password_confirmation: password
    }
    @new_user_hash = {
      email: @email,
      username: @username,
      name: Faker::Name.unique.name,
      password: password,
      password_confirmation: password
    }
  end

  test "should not save user if email is not unique" do
    user = User.new(@existed_email_hash)
    assert_equal false, user.save
  end

  test "should not save user if username is not unique" do
    user = User.new(@existed_username_hash)
    assert_equal false, user.save
  end

  test "should downcase the email and username before save" do
    user = User.new(@new_user_hash)
    assert user.save
    user.reload
    assert_equal @email.downcase, user.email
    assert_equal @username.downcase, user.username
  end
end
