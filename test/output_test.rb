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

    def test_status_returns_disconnected_when_output_is_not_connected
      o = Output.new name: 'out1', connected: false

      assert_equal 'disconnected', o.status
    end

    def test_status_returns_on_when_output_has_current_mode_set
      o = Output.new name: 'out1', connected: true, modes: [ Mode.new(current: true, rate: '60hz', preferred: true, resolution: '1920x1080') ]

      assert_equal 'on', o.status
    end

    def test_status_returns_off_when_output_has_no_current_mode_set
      o = Output.new name: 'out1', connected: true, modes: [ Mode.new(current: false, rate: '60hz', preferred: false, resolution: '1920x1080') ]

      assert_equal 'off', o.status
    end
  end
end
