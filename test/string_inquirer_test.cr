require "minitest/autorun"

require "../src/activesupport/string_inquirer"

class StringInquirerTest < Minitest::Test
  property! :string_inquirer

  def setup
    @string_inquirer = ActiveSupport::StringInquirer.new("production")
  end

  def test_match
    assert string_inquirer.production?
  end

  def test_miss
    refute string_inquirer.development?
  end

  def test_delegates_to_string
    assert_equal "PRODUCTION", string_inquirer.upcase
    assert_equal 10, string_inquirer.length
  end
end
