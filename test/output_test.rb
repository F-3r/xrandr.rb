require_relative 'helper'
require_relative '../lib/xrandr'

module Xrandr
  class OutputTest < Minitest::Test
    def test_new_raises_if_no_name
      assert_raises ArgumentError do
        Output.new connected: false
      end
    end

    def test_new_raises_if_no_connection_info
      assert_raises ArgumentError do
        Output.new name: 'o'
      end
    end
  end
end
