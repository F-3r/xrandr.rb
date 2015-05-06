# xrandr

A ruby interface to [xrandr](http://www.x.org/wiki/Projects/XRandR/)

## Install

`gem install xrandr`

(or use your preferred gemset/dependency management tool)

## Usage

### Outputs

Gives you the status of each of the outputs

```ruby

Xrandr.new.outputs #=> [ <Xrandr::Output{ id: 1, name: 'LVDS1', connected: true, mode: '1920x1080' }>, <Xrandr::Output { id: 2, name: 'VGA1', connected: false }> ]

```

Access specific output parameters

```ruby
randr = Xrandr.new
vga = randr.output(1)

vga.connected #=> true
vga.name #=> 'VGA1'
vga.mode #=> '1920x1080'

```

```ruby
randr = Xrandr.new
vga = randr.output('VGA1')

vga.connected #=> true
vga.name #=> 'VGA1'
vga.mode #=> '1920x1080'

```

### Configure


```ruby
xrandr = Xrandr.new

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

Open an issue, lets talk.

## License

See UNLICENSE
