# xrandr

A ruby interface to [xrandr](http://www.x.org/wiki/Projects/XRandR/)

## Install

`gem install xrandr`

(or use your preferred gemset/dependency management tool)

## Usage

### Outputs

Gives you the status of each of the outputs

```ruby

Xrandr::Control.new.outputs #=> [#<Xrandr::Output:0x00557ed8ed80a8 @name="eDP1", @connected=true, @primary=true, @resolution="1920x1080", @position="0x0", @info="(normal left inverted right x axis y axis)", @dimensions="344mm x 193mm", @modes=[#<Xrandr::Mode:0x00557ed8ed9cc8 @resolution="1920x1080", @rate="60.0", @current=true, @preferred=true>, ... ]>, #<Xrandr::Output:0x00557ed8711f40 @name="DP1", @connected=false, @primary=false, @resolution=nil, @position=nil, @info="(normal left inverted right x axis y axis)", @dimensions=nil, @modes=[]>, ... ]

```

Access specific output parameters by index

```ruby
xrandr = Xrandr::Control.new

vga = xrandr.find_output(1)
# or
vga = xrandr[1]

vga.status #=> 'on'  # possible values are:  'on'`, 'off' or 'disconnected'

vga.connected #=> true
vga.name #=> 'VGA1'
vga.current # returns the current Xrandr::Mode for this display. nil if disconnected or off

```

Access specific output parameters by name

```ruby
x = Xrandr::Control.new

vga = xrandr.find_output('VGA1')
# or
vga = xrandr['VGA1']

vga.connected #=> true
vga.name #=> 'VGA1'
vga.current #=> '1920x1080'

```

### Configure


```ruby
xrandr = Xrandr::Control.new

# setting global options
xrandr.configure(fb: '1920x1080', no_primary: true)


# setting per output options
xrandr.configure('VGA1', auto: true)

# also, can specify the output by index
xrandr.configure('VGA2', mode: '1920x1080', right_of: 'VGA1')


```

After all outputs are configured, call `#apply!` to execute the command.

```ruby

xrandr.apply!

```

or call `#command`, to get the command line string that would be run
```ruby

xrandr.command #=> "xrandr --fb 1920x1080 --no_primary --output VGA1 --auto --output LVDS1 --mode 1920x1080 --pos 1921x0"

```

For all available configuration parameter see you can `man xrandr`

## Contributing

Open an issue, a PR, or whatever you feel comfortable with.

## License

See UNLICENSE
