ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

require "capybara/rails"
require "capybara/minitest"
require "selenium-webdriver"

Capybara.server_host = "0.0.0.0"
Capybara.app_host = "http://#{ENV.fetch("APP_HOST", `hostname`.strip&.downcase || "0.0.0.0")}"

Capybara.register_driver :selenium_firefox_remote do |app|
  Capybara::Selenium::Driver.new(app,
    browser: :remote,
    url: "http://selenium:4444/wd/hub",
    capabilities: :firefox)
end

Capybara.javascript_driver = :selenium_firefox_remote

class Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
end
