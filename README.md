# DumbDelegator

[![Gem Version](http://img.shields.io/gem/v/dumb_delegator.svg)](https://rubygems.org/gems/dumb_delegator)
[![Build Status](https://img.shields.io/travis/stevenharman/dumb_delegator.svg)](https://travis-ci.org/stevenharman/dumb_delegator)
[![Code Climate](http://img.shields.io/codeclimate/github/stevenharman/dumb_delegator.svg)](https://codeclimate.com/github/stevenharman/dumb_delegator)
[![Dependency Status](https://img.shields.io/gemnasium/stevenharman/dumb_delegator.svg)](https://gemnasium.com/stevenharman/dumb_delegator)

Ruby provides the `delegate` standard library. However, we found that it is not
appropriate for many use cases that require nearly every call to be proxied.

For instance, Rails uses `#class` and `#instance_of?` to introspect on model
classes when generating forms and URL helpers. These methods are not forwarded
when using `Delegator` or `SimpleDelegator`.

```ruby
require 'delegate'

class MyAwesomeClass
  # ...
end

o = MyAwesomeClass.new
d = SimpleDelegator.new(o)

d.class                # => SimpleDelegator
d.is_a? MyAwesomeClass # => false
```

`DumbDelegator`, on the other hand, forwards almost ALL the things:

```ruby
require 'dumb_delegator'

class MyAwesomeClass
  # ...
end

o = MyAwesomeClass.new
d = DumbDelegator.new(o)

d.class                # => MyAwesomeClass
d.is_a? MyAwesomeClass # => true
```

## Usage

### Rails Model Decorator

There are [many decorator
implementations](http://robots.thoughtbot.com/post/14825364877/evaluating-alternative-decorator-implementations-in)
in Ruby. One of the simplest is "SimpleDelegator + super + getobj," but it has
the drawback of confusing Rails. It is necessary to redefine `class`. We've
also observed the need to redefine `instance_of?` for URL helpers.

With `DumbDelegator`, there's not a need for this hackery because nearly every
possible method is delegated:

```ruby
require 'dumb_delegator'

class Coffee
  def cost
    2
  end

  def origin
    'Colombia'
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
Sugar.new(Milk.new(coffee)).cost   # 2.6
Sugar.new(Sugar.new(coffee)).cost  # 2.4
Milk.new(coffee).origin            # Colombia
Sugar.new(Milk.new(coffee)).class  # Coffee
```

## Installation

Add this line to your application's Gemfile:

    gem 'dumb_delegator'

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
