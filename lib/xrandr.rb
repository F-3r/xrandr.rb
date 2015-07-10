module Xrandr
  VERSION = '0.0.1'

  class Control
    attr_reader :screens, :outputs, :command

    def initialize(parser = Parser.new)
      @screens, @outputs = * parser.parse
      @command = 'xrandr'
    end

    def configure(output = nil, **options)
      output = find_output(output) if output

      command << " --output #{output.name}" if output
      command << options.map do |option, value|
        value = nil if value == true
        " --#{option} #{value}".rstrip
      end.join(' ')
    end

    def find_output(output)
      if output.kind_of? Output
        output
      elsif output.kind_of? String
        outputs.find {|o| o.name == output}
      elsif output.kind_of? Integer
        outputs[output]
      else
        raise ArgumentError, "Expecting a string, an integer or an Xrandr::Output instance"
      end
    end
    alias_method :[], :find_output

    def apply!
      Kernel.system(command)
      initialize
    end
  end

  class Parser
    attr_reader :data
    def initialize(data = `xrandr --query`)
      @data = data
    end

    def parse
      screens_data, outputs_data = data.split("\n").group_by {|line| line.start_with?('Screen') }.values

      [ parse_screens(screens_data), parse_outputs(outputs_data) ]
    end

    def parse_screens(data); []; end # TODO

    def parse_outputs(data)
      # join output info line with each of its modes
      data = data.slice_when {|before, after| !after.start_with?(' ')}

      data.map do |output_data|
        parse_output(output_data)
      end
    end

    def parse_output(data)
      data, *modes = data

      args = {
              name:       /[a-zA-Z0-9\-\_]+/,
              connected:  /connected|disconnected/,
              primary:    /primary/,
              resolution: /\d+x\d+\+\d+\+\d+/,
              info:       /\([^\)]+\)/,
              dimensions: /[0-9+]+mm x [0-9]+mm/,
             }
      .map {|token, regex| [token, data.scan(regex).first] }
      .to_h

      # split resolution and position values split all values, coherce to integers, split the array in halfs, assign each half)
      args[:resolution], args[:position] = args[:resolution].split(/x|\+/).each_slice(2).map {|v| v.join('x') }  if args[:resolution]

      # Coherce parameters
      args[:connected] = args[:connected] == 'connected'
      args[:primary]   = args[:primary] == 'primary'

      # Parse modes
      args[:modes] = parse_modes(modes)

      Output.new args
    end

    def parse_modes(modes)
      modes.map do |data|
        parse_mode data
      end
    end

    def parse_mode(data)
      matches = data.lstrip.match(/^(?<resolution>\d+x\d+i?) +(?<rate>[\d\.]+)(?<current>[\* ])(?<preferred>[\+ ]).*/)

      resolution = matches[:resolution].gsub 'i', '' if matches[:resolution]
      args = {
              resolution: resolution,
              rate: matches[:rate],
              current: matches[:current] == '*',
              preferred: matches[:preferred] == '+',
             }

      Mode.new args
    end
  end

  class Output
    attr_reader :name, :connected, :primary, :resolution, :position, :info, :dimensions, :modes

    def initialize(name:, connected:, primary: false, resolution: nil, position: nil, info: '', dimensions: '', modes: [])
      raise ArgumentError, "must provide a name for the output" unless name
      raise ArgumentError, "connected cant be nil" unless connected == true || connected == false
      @name = name
      @connected = connected
      @primary = primary
      @resolution = resolution
      @position = position
      @info = info
      @dimensions = dimensions
      @modes = modes
    end

    def current
      modes.detect(&:current)
    end

    def preferred
      modes.detect(&:preferred)
    end
  end

  class Mode
    attr_reader :resolution, :rate, :current, :preferred

    def initialize(args={})
      @resolution = args.fetch :resolution
      @rate = args.fetch :rate
      @current = args.fetch :current
      @preferred = args.fetch :preferred
    end
  end
end
