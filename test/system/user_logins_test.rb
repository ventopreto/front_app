require "application_system_test_case"

class UserLoginTest < ApplicationSystemTestCase
  setup do
    Capybara.current_driver = :selenium_firefox_remote
    @user = User.create!(email: "madmax@furyroad.com", password: "interceptor",
      password_confirmation: "interceptor")
  end

  test "user signup with valid email and password should get a valid jwt token" do
    visit "users/sign_up"

    fill_in "Email", with: "marty@mcFly.com"
    fill_in "Password", with: "DeLorean"
    fill_in "Password confirmation", with: "DeLorean"

    click_on "Sign up"

    assert_text "Welcome! You have signed up successfully"
    assert_match(/Bearer .*/, page.body)
    assert_current_path root_path
  end

  test "user authenticated with email and password should get a valid jwt token" do
    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "interceptor"

    click_on "Log in"

    assert_text "Signed in successfully"
    assert_match(/Bearer .*/, page.body)
    assert_current_path root_path
  end

  test "user unauthenticated should not get a valid jwt token" do
    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "intercepto"

    click_on "Log in"

    assert_text "Invalid Email or password."
  end

  test "user authenticated with github should get a valid jwt token" do
    valid_login_with_github_oauth
    visit user_github_omniauth_callback_path
    assert_text "Successfully authenticated from Github account"
    assert_match(/Bearer .*/, page.body)
  end

  test "user unauthenticated with github should not get a valid jwt token" do
    invalid_login_with_github_oauth
    visit user_github_omniauth_callback_path
    assert_no_text "Successfully authenticated from Github account"
    assert_no_match(/Bearer .*/, page.body)
  end

  test "user authenticated with facebook should get a valid jwt token" do
    valid_login_with_facebook_oauth
    visit user_facebook_omniauth_callback_path
    assert_text "Successfully authenticated from Facebook account"
    assert_match(/Bearer .*/, page.body)
  end

  test "user unauthenticated with facebook should not get a valid jwt token" do
    invalid_login_with_facebook_oauth
    visit user_facebook_omniauth_callback_path
    assert_no_text "Successfully authenticated from Facebook account"
    assert_no_match(/Bearer .*/, page.body)
  end
end
