ENV['ENV'] ||= 'development'
require 'byebug' if ENV['ENV'] == 'development'

module Xrandr
  VERSION = '0.0.1'

  class Command
    def initialize(output)
      @output = output
    end
  end

  class Parser
    attr_reader :outputs
    def initialize(data=`xrandr --query`)
      @screens, @outputs = parse data
    end

    def parse(data)
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
              name:       /[a-zA-Z0-9]+/,
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
      matches = data.lstrip.match(/^(?<resolution>\d+x\d+) +(?<rate>[\d\.]+)(?<current>[\* ])(?<preferred>[\+ ])/)

      args = {
              resolution: matches[:resolution],
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
      raise ArgumentError "must provide a name for the output" unless name
      raise ArgumentError "connected cant be nil" unless connected == true || connected == false
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
