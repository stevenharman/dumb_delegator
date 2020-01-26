# DumbDelegator

[![Gem Version](https://badge.fury.io/rb/dumb_delegator.svg)](https://badge.fury.io/rb/dumb_delegator)
[![Build Status](https://travis-ci.org/stevenharman/dumb_delegator.svg?branch=master)](https://travis-ci.org/stevenharman/dumb_delegator)
[![Maintainability](https://api.codeclimate.com/v1/badges/b684cbe08af745cbe957/maintainability)](https://codeclimate.com/github/stevenharman/dumb_delegator/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b684cbe08af745cbe957/test_coverage)](https://codeclimate.com/github/stevenharman/dumb_delegator/test_coverage)


Ruby provides the `delegate` standard library.
However, we found that it is not appropriate for cases that require nearly every call to be proxied.

For instance, Rails uses `#class` and `#instance_of?` to introspect on model classes when generating forms and URL helpers.
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

## Usage

### Rails Model Decorator

There are [many decorator implementations](http://robots.thoughtbot.com/post/14825364877/evaluating-alternative-decorator-implementations-in) in Ruby.
One of the simplest is "`SimpleDelegator` + `super` + `__getobj__`," but it has the drawback of confusing Rails.
It is necessary to redefine `#class`.
We've also observed the need to redefine `#instance_of?` for URL helpers.

With `DumbDelegator`, there's not a need for this hackery because nearly every possible method is delegated:

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
Milk.new(coffee).origin           #=> Colombia
Sugar.new(Sugar.new(coffee)).cost #=> 2.4

cup_o_coffee = Sugar.new(Milk.new(coffee))
cup_o_coffee.cost                 #=> 2.6
cup_o_coffee.class                #=> Coffee
cup_o_coffee.is_a?(Coffee)        #=> true
cup_o_coffee.is_a?(Milk)          #=> true
cup_o_coffee.is_a?(Sugar)         #=> true
```

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

## Installation

Add this line to your application's Gemfile:

    gem "dumb_delegator"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dumb_delegator

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contribution Ideas/Needs

1. Ruby 1.8 support (use the `blankslate` gem?)
