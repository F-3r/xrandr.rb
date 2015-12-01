require_relative 'helper'
require_relative '../lib/xrandr'

module Xrandr

  class Parser::ParseOutputTest < Minitest::Test
    def test_parse_outputs_returns_an_array_of_outputs
      o = [
           "LVDS1 connected primary 1366x768+0+0 (normal left inverted right x axis y axis) 309mm x 174mm",
           "  1366x768      60.07*+","  1024x768      60.00  ",
           "  800x600       60.32    56.25  ",
           "  640x480       59.94  ",
           "VGA1 connected 1920x1080+1366+0 (normal left inverted right x axis y axis) 309mm x 174mm",
           "  1920x1080      60.07*+",
           "  1024x768      60.00  ",
           "  800x600       60.32    56.25  ",
           "  640x480       59.94  ",
           "DP1 disconnected (normal left inverted right x axis y axis)",
           "DP2 disconnected (normal left inverted right x axis y axis)"
          ]

      outputs = Parser.new.parse_outputs o

      assert 4, outputs.size
      assert outputs[0].connected
      assert outputs[1].connected
      refute outputs[2].connected
      refute outputs[3].connected
      assert 3, outputs[0].modes.size
      assert 4, outputs[1].modes.size
    end

    def test_parses_connected_output_lines
      session = Parser.new
      o = ["LVDS1 connected 1366x768+0+0 (normal left inverted right x axis y axis) 309mm x 174mm","  1366x768      60.07*+","  1024x768      60.00  ","  800x600       60.32    56.25  ","  640x480       59.94  "]

      output = session.parse_output o

      assert_equal "LVDS1", output.name
      assert output.connected
      assert_equal '1366x768', output.resolution
      assert_equal '0x0', output.position
      assert_equal '(normal left inverted right x axis y axis)', output.info
      assert_equal '309mm x 174mm', output.dimensions
      assert_equal 4, output.modes.size
      refute output.primary
    end

    def test_parses_primary
      session = Parser.new
      o = ['LVDS1 connected primary 1366x768+0+0 (normal left inverted right x axis y axis) 309mm x 174mm',"  1366x768      60.07*+","  1024x768      60.00  ","  800x600       60.32    56.25  ","  640x480       59.94  "]

      output = session.parse_output o

      assert_equal "LVDS1", output.name
      assert output.connected
      assert_equal '1366x768', output.resolution
      assert_equal '0x0', output.position
      assert_equal '(normal left inverted right x axis y axis)', output.info
      assert_equal '309mm x 174mm', output.dimensions
      assert output.primary
      assert_equal 4, output.modes.size
    end

    def test_parses_disconnected_output_lines
      session = Parser.new
      output = session.parse_output ["DP1 disconnected (normal left inverted right x axis y axis)"]

      refute output.connected
      assert_equal 'DP1', output.name
      assert_equal '(normal left inverted right x axis y axis)', output.info
      assert_nil output.dimensions
      assert_nil output.resolution
      assert_nil output.position
      assert_empty output.modes
      refute  output.primary
    end

    def test_parse_output_recognizes_virtual_output_format
      # when disconnecting a display that is actually being used, xrandr leaves a Virtual display with this kind of output
      output = [
                'VIRTUAL1 disconnected (normal left inverted right x axis y axis)',
                '  1920x1080 (0x4b) 148.500MHz',
                '        h: width  1920 start 2008 end 2052 total 2200 skew    0 clock  67.50KHz',
                '        v: height 1080 start 1084 end 1089 total 1125           clock  60.00Hz'
               ]

      output = Parser.new.parse_output output

      assert_equal 'VIRTUAL1', output.name
      refute output.connected
      assert_equal '(normal left inverted right x axis y axis)', output.info
      assert_nil output.dimensions
      assert_nil output.resolution
      assert_nil output.position
      assert_empty output.modes
    end

  end

  class Parser::ParseModeTest < Minitest::Test
    def test_returns_a_mode
      mode = Parser.new.parse_mode("   1366x768      60.07*+")
      assert_equal '1366x768', mode.resolution
      assert_equal '60.07', mode.rate
      assert mode.current
      assert mode.preferred
    end

    def test_parses_preferred_attribute_correctly
      mode = Parser.new.parse_mode("   1366x768      60.07 +")
      assert mode.preferred
      mode = Parser.new.parse_mode("   1366x768      60.07  ")
      refute mode.preferred

      mode = Parser.new.parse_mode("   1366x768      60.07*+")
      assert mode.preferred
      mode = Parser.new.parse_mode("   1366x768      60.07* ")
      refute mode.preferred
    end

    def test_parses_current_attribute_correctly
      mode = Parser.new.parse_mode("   1366x768      60.07* ")
      assert mode.current
      mode = Parser.new.parse_mode("   1366x768      60.07  ")
      refute mode.current

      mode = Parser.new.parse_mode("   1366x768      60.07*+")
      assert mode.current
      mode = Parser.new.parse_mode("   1366x768      60.07 +")
      refute mode.current
    end

    def test_parse_modes_returns_a_collection_of_modes
      session = Parser.new
      modes = session.parse_modes ["   1024x768      60.00 +", "   1920x1080      60.00  ", "   1366x768      60.07* "]

      assert_equal "1024x768", modes[0].resolution
      assert_equal "1920x1080", modes[1].resolution
      assert_equal "1366x768", modes[2].resolution
    end

    # some systems names the modes like 1920x1080i
    def test_parse_modes_allows_i_suffix
      session = Parser.new
      modes = session.parse_modes ["   1024x768i      60.00 +", "   1920x1080i      60.00  ", "   1366x768i      60.07* "]

      assert_equal "1024x768", modes[0].resolution
      assert_equal "1920x1080", modes[1].resolution
      assert_equal "1366x768", modes[2].resolution
    end
  end
end
