require_relative 'helper'
require_relative '../lib/xrandr'

module Xrandr
  class XrandrTest < Minitest::Test
    def outputs
      [ Output.new(name: 'VGA1', connected: true), Output.new(name: 'VGA2', connected: true), Output.new(name: 'VGA3', connected: true) ]
    end
  end

  class ControlTest < XrandrTest
    def test_find_ouput_finds_an_output_by_name
      parser = MockParser.new([], outputs)
      xrandr = Control.new(parser)
      output = outputs[2]

      assert_equal outputs[2].name, xrandr.find_output(output).name
    end

    def test_find_ouput_finds_an_output_by_name
      parser = MockParser.new([], outputs)
      xrandr = Control.new(parser)

      assert_equal outputs[1].name, xrandr.find_output('VGA2').name
    end

    def test_find_ouput_finds_an_output_by_index
      parser = MockParser.new([], outputs)

      xrandr = Control.new(parser)

      assert_equal outputs[1].name, xrandr.find_output(1).name
    end
  end

  class XrandrConfigureGlobalParametersTest < XrandrTest
    def test_param_with_arguments
      xrandr = Control.new MockParser.new([], [])
      xrandr.configure fb: '2000x2000'

      assert_equal 'xrandr --fb 2000x2000', xrandr.command
    end

    def test_switch_param
      xrandr = Control.new MockParser.new([], [])
      xrandr.configure noprimary: true

      assert_equal 'xrandr --noprimary', xrandr.command
    end
  end

  class XrandrConfigureOutputParametersTest < XrandrTest
    def test_configure_output_by_name
      xrandr = Control.new MockParser.new([], outputs)

      xrandr.configure 'VGA1', mode: '2000x2000'

      assert_equal 'xrandr --output VGA1 --mode 2000x2000', xrandr.command
    end

    def test_configure_output_by_index
      xrandr =  Control.new MockParser.new([], outputs)

      xrandr.configure 0, primary: true

      assert_equal 'xrandr --output VGA1 --primary', xrandr.command
    end

    def test_configure_output_param_with_a_switch_argument
      xrandr = Control.new MockParser.new([], outputs)
      xrandr.configure 'VGA1', primary: true

      assert_equal 'xrandr --output VGA1 --primary', xrandr.command
    end
  end

  MockParser = Struct.new(:screens, :outputs) do
    def parse
      [screens, outputs]
    end
  end
end
