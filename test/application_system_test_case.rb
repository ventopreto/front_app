require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
end
