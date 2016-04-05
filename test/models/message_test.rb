require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @message = Message.new(name: "Example", number: "4105551234", content: "sample content", from: "4105554321")
  end

  test "should be valid" do
    assert @message.valid?
  end

  test "name should have a maximum length" do
    @message.name = "a" * 51
    assert_not @message.valid?
  end

  test "number should have a maximum length" do
    @message.number = "1" * 17
    assert_not @message.valid?
  end

  test "number should be of a reasonable format" do
    @message.number = "+1234a"
    assert_not @message.valid?
  end

  test "content should have a maximum length" do
    @message.content = "a" * 123
    assert_not @message.valid?
  end
end
