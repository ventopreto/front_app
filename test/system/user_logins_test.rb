require "application_system_test_case"

class UserLoginTest < ApplicationSystemTestCase

  setup do
    Capybara.current_driver = :selenium_firefox_remote
    @user = User.create!(email: "madmax@furyroad.com", password: "interceptor",
      password_confirmation: "interceptor")
  end

  test "user can log in using email and password" do
    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "interceptor"

    click_on "Log in"

    assert_text "Signed in successfully"
    assert_current_path root_path
  end

  test "login with Facebook" do
    visit new_user_session_path

    click_on "Sign in with Facebook"

    assert_text "Log Into Facebook"
    assert_current_path(/www.facebook.com/)
  end

  test "login with GitHub" do
    visit new_user_session_path

    click_on "Sign in with GitHub"

    assert_text "Sign in to GitHub"
  end
end
