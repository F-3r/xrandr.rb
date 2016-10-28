
module Xrandr

  # Some methods for automatic display detection and configuration
  class Configurator
    # Many drivers (intel, nouveau) assign 'eDP-1' or 'eDP1' to the internal port
    DEFAULT_INTERNAL_PORT = /eDP.*/
    # Builtin display resolution for the retina macbook pro (2013)
    DEFAULT_INTERNAL_RES = '2880x1800'.freeze

    attr_reader :xrandr
    attr_accessor :internal_display_matcher, :internal_display_resolution

    def initialize
      @xrandr = Xrandr::Control.new
      @internal_display_matcher = DEFAULT_INTERNAL_PORT
      @internal_display_resolution = DEFAULT_INTERNAL_RES
    end

    ##
    # Attempt to identify the internal display using a simple heuristic...
    def identify_internal_display
      # ... match based on a port name regex initially
      internal = @xrandr.connected_outputs.select do |o|
        o.name =~ @internal_display_matcher
      end
      # ... fall back to resolution based detection if that fails
      if internal.length.zero?
        internal = @xrandr.connected_outputs.select { |o| o.resolution == @internal_display_resolution }
      end

      internal[0]
    end

    def identify_external_displays(internal_display)
      @xrandr.connected_outputs.select { |display| display != internal_display }
    end

    def identify_displays
      internal = identify_internal_display
      external = identify_external_displays(internal)
      raise RuntimeError("No displays found - which seems unlikely") if internal.nil? && external.length.zero?
      [internal, external]
    end

    ##
    # Sorts an array of displays on the basis of a preferred port ID if specified
    # or maximum resolution if not
    def sort_displays(displays, preferred_output_id = /.*/)
      sorted = displays.sort_by do |d|
        preferred = d.name =~ preferred_output_id
        [preferred, d.preferred.resolution]
      end
      sorted.reverse!
    end

    # Stack displays vertically, centering based on max reported horizontal pixel count
    #
    # @param displays [Array<Xrandr::Output>] of displays to stack - must
    #    contain at least one non-nil value
    def stack(displays)
      displays.compact! # Remove nil entries
      raise ArgumentException('No displays to stack') if displays.length.zero?
      ref = displays.max { |a, b| a.preferred.resolution.x <=> b.preferred.resolution.x }
      y_offset = 0

      displays.each do |d|
        x_offset = (ref.preferred.resolution.x - d.preferred.resolution.x) / 2
        @xrandr.configure(d.name, auto: true, pos: "#{x_offset}x#{y_offset}")
        y_offset += d.preferred.resolution.y
      end
    end

    # Align one or more displays to the right of a reference
    #
    # @param reference_display [Xrandr::Output] The leftmost display. This must
    #        be configured before being passed to this method
    # @param additional_displays [Array<Xrandr::Output>] May be empty
    def position_right_of(reference_display, additional_displays)
      return if reference_display.nil?
      # Only using the reference display resolution for now, but will need
      # position info to layout multiple rows at a later date, so better to pass
      # display than introduce a breaking api change later
      ref = reference_display.preferred.resolution
      x_offset = ref.x
      additional_displays.each do |d|
        res = d.preferred.resolution
        y_offset = res.y < ref.y ? (ref.y - res.y) / 2 : 0
        @xrandr.configure(d.name, auto: true, pos: "#{x_offset}x#{y_offset}")
        x_offset += res.x
      end
    end

    def disable(outputs)
      outputs.each { |o| @xrandr.configure(o.name, off: true) }
    end

    # An opinionated auto-configuration method
    # Attempts to identify any internal (laptop) and all connected external
    # displays and configures them on the basis of the following assumptions:
    # 1. The highest resolution (primary) external monitor is directly in front of you
    # 2. Any additional external monitors are to the right of the primary
    # 3. Any internal laptop display is enabled and located directly below the primary
    # Should work with any combination of internal and external monitors. My i3wm
    # config file invokes it at startup and also binds it to <mod>+m, so I just
    # hit <mod>+m any time I connect or disconnect a display 
    def auto(dryrun = false, preferred_output_id = nil)

      internal, external = identify_displays
      external = sort_displays(external, preferred_output_id) # Sort by port ID / max resolution
      stack([external[0], internal])
      position_right_of(external[0], external[1..-1])

      # This is necessary to make some wms (e.g. i3) reassociate desktops with a
      # connected screen after you detach an external monitor
      disable(@xrandr.disconnected_outputs)

      @xrandr.apply! unless dryrun

      # Return the command string
      @xrandr.command

    end

  end
end