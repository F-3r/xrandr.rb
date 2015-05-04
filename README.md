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

vga.connected? #=> true
vga.name #=> 'VGA1'
vga.mode #=> '1920x1080'

```

### Configure

You can set outputs parameters by index or by name:

```ruby
randr = Xrandr.instance

randr.configure(1).mode(1024, 768).position(1024, 0)

randr.configure('VGA1').right_of('LVDS1')

randr.configure(LVDS1').below(1)

```

After all outputs are configured, call `#apply!` to execute the command.


```ruby

randr.apply!

```

For all available configuration parameter see [???]

## Contributing

Open an issue, lets talk!

## License

See UNLICENSE
