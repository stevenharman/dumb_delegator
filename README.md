# DumbDelegator

[![Gem Version](https://badge.fury.io/rb/dumb_delegator.svg?icon=si%3Arubygems&icon_color=%23ff2600)](https://badge.fury.io/rb/dumb_delegator)
[![CI](https://github.com/stevenharman/dumb_delegator/actions/workflows/ci.yml/badge.svg)](https://github.com/stevenharman/dumb_delegator/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/b684cbe08af745cbe957/maintainability)](https://codeclimate.com/github/stevenharman/dumb_delegator/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b684cbe08af745cbe957/test_coverage)](https://codeclimate.com/github/stevenharman/dumb_delegator/test_coverage)

Ruby provides the `delegate` standard library.
However, we found that it is not appropriate for cases that require nearly every call to be proxied.

For instance, Rails uses `#class` and `#instance_of?` to introspect on Model classes when generating forms and URL helpers.
These methods are not forwarded when using `Delegator` or `SimpleDelegator`.

```ruby
require "delegate"

class MyAwesomeClass
  # ...
end

o = MyAwesomeClass.new
d = SimpleDelegator.new(o)

d.class                #=> SimpleDelegator
d.is_a? MyAwesomeClass #=> false
```

`DumbDelegator`, on the other hand, forwards almost ALL THE THINGS:

```ruby
require "dumb_delegator"

class MyAwesomeClass
  # ...
end

o = MyAwesomeClass.new
d = DumbDelegator.new(o)

d.class                #=> MyAwesomeClass
d.is_a? MyAwesomeClass #=> true
```

## Installation

Add this line to your Gemfile:

```ruby
gem "dumb_delegator"
```

And then install:

```bash
$ bundle
```

Or install it yourself:

```bash
$ gem install dumb_delegator
```

### Versioning

This project adheres to [Semantic Versioning][semver].

#### Version `0.8.x`

The `0.8.0` release was downloaded 1.2MM times before the `1.0.0` work began.
Which is great! 🎉
But, we wanted to clean up some cruft, fix a few small things, and improve ergonomics.
And we wanted to do all of that while, hopefully, not breaking existing usage.

To that end, `1.0.0` dropped support for all [EoL'd Rubies][ruby-releases] and only officially supported Ruby `2.4` - `2.7` when it was released.
However, most older Rubies, _should_ still work.
Maybe… Shmaybe?
Except for Ruby 1.9, which probably _does not work_ with `DumbDelegator` `> 1.0.0`.
If you're on an EoL'd Ruby, please try the `0.8.x` versions of this gem.

## Usage

`DumbDelegator`'s API and usage patters were inspired by Ruby stdlib's `SimpleDelegator`.
So the usage and ergonomics are quite similar.

```ruby
require "dumb_delegator"

class Coffee
  def cost
    2
  end

  def origin
    "Colombia"
  end
end

class Milk < DumbDelegator
  def cost
    super + 0.4
  end
end

class Sugar < DumbDelegator
  def cost
    super + 0.2
  end
end

coffee = Coffee.new

cup_o_coffee = Sugar.new(Milk.new(coffee))
cup_o_coffee.origin        #=> Colombia
cup_o_coffee.cost          #=> 2.6

# Introspection
cup_o_coffee.class         #=> Coffee
cup_o_coffee.__getobj__    #=> #<Coffee:0x00007fabed1d6910>
cup_o_coffee.inspect       #=> "#<Sugar:70188197507600 obj: #<Milk:70188197507620 obj: #<Coffee:0x00007fabed1d6910>>>"
cup_o_coffee.is_a?(Coffee) #=> true
cup_o_coffee.is_a?(Milk)   #=> true
cup_o_coffee.is_a?(Sugar)  #=> true
```

### Rails Model Decorator

There are [many decorator implementations](http://robots.thoughtbot.com/post/14825364877/evaluating-alternative-decorator-implementations-in) in Ruby.
One of the simplest is "`SimpleDelegator` + `super` + `__getobj__`," but it has the drawback of confusing Rails.
It is necessary to redefine `#class`, at a minimum.
If you're relying on Rails' URL Helpers with a delegated object, you also need to redefine `#instance_of?`.
We've also observed the need to redefine other Rails-y methods to get various bits of 🧙 Rails Magic 🧙 to work as expected.

With `DumbDelegator`, there's not a need for redefining these things because nearly every possible method is delegated.

### Optional `case` statement support

Instances of `DumbDelegator` will delegate `#===` out of the box.
Meaning an instance can be used in a `case` statement so long as the `when` clauses rely on instance comparison.
For example, when using a `case` with a regular expression, range, etc...

It's also common to use Class/Module in the `where` clauses.
In such usage, it's the Class/Module's `::===` method that gets called, rather than the `#===` method on the `DumbDelegator` instance.
That means we need to override each Class/Module's `::===` method, or even monkey-patch `::Module::===`.

`DumbDelegator` ships with an optional extension to override a Class/Module's `::===` method.
But you need to extend each Class/Module you use in a `where` clause.

```ruby
def try_a_case(thing)
  case thing
  when MyAwesomeClass
    "thing is a MyAwesomeClass."
  when DumbDelegator
    "thing is a DumbDelegator."
  else
    "Bad. This is bad."
  end
end

target = MyAwesomeClass.new
dummy = DumbDelegator.new(target)

try_a_case(dummy) #=> thing is a DumbDelegator.

MyAwesomeClass.extend(DumbDelegator::TripleEqualExt)

try_a_case(dummy) #=> thing is a MyAwesomeClass.
```

#### Overriding `Module::===`
If necessary, you could also override the base `Module::===`, though that's pretty invasive.

🐲 _There be dragons!_ 🐉

```ruby
::Module.extend(DumbDelegator::TripleEqualExt)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contribution Ideas/Needs

1. Ruby 1.8 support (use the `blankslate` gem?)


[ruby-releases]: https://www.ruby-lang.org/en/downloads/branches/ "The current maintenance status of the various Ruby branches"
[semver]: https://semver.org/spec/v2.0.0.html "Semantic Versioning 2.0.0"
