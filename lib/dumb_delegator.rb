# frozen_string_literal: true

require "dumb_delegator/triple_equal_ext"
require "dumb_delegator/version"

##
# @example
# class Coffee
#   def cost
#     2
#   end
#
#   def origin
#     "Colombia"
#   end
# end
#
# class Milk < DumbDelegator
#   def cost
#     super + 0.4
#   end
# end
#
# class Sugar < DumbDelegator
#   def cost
#     super + 0.2
#   end
# end
#
# coffee = Coffee.new
# Milk.new(coffee).origin           #=> Colombia
# Sugar.new(Sugar.new(coffee)).cost #=> 2.4
#
# cup_o_coffee = Sugar.new(Milk.new(coffee))
# cup_o_coffee.cost                 #=> 2.6
# cup_o_coffee.class                #=> Coffee
# cup_o_coffee.is_a?(Coffee)        #=> true
# cup_o_coffee.is_a?(Milk)          #=> true
# cup_o_coffee.is_a?(Sugar)         #=> true
class DumbDelegator < ::BasicObject
  (::BasicObject.instance_methods - [:equal?, :__id__, :__send__, :method_missing]).each do |method|
    undef_method(method)
  end

  kernel = ::Kernel.dup
  (kernel.instance_methods - [:dup, :clone, :method, :methods, :respond_to?, :object_id]).each do |method|
    kernel.__send__(:undef_method, method)
  end
  include kernel

  def initialize(target)
    __setobj__(target)
  end

  def inspect
    "#<#{(class << self; self; end).superclass}:#{object_id} obj: #{__getobj__.inspect}>"
  end

  def methods(all = true)
    __getobj__.methods(all) | super
  end

  def method_missing(method, *args, &block)
    if __getobj__.respond_to?(method)
      __getobj__.__send__(method, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    __getobj__.respond_to?(method, include_private) || super
  end

  # @return [Object] The object calls are being delegated to
  def __getobj__
    @__dumb_target__
  end

  # @param obj [Object] Change the object delegate to +obj+.
  def __setobj__(obj)
    raise ::ArgumentError, "Delegation to self is not allowed." if obj.__id__ == __id__
    @__dumb_target__ = obj
  end

  def marshal_dump
    [
      :__v1__,
      __getobj__
    ]
  end

  def marshal_load(data)
    version, obj = data
    case version
    when :__v1__
      __setobj__(obj)
    end
  end

  private

  def initialize_dup(obj)
    __setobj__(obj.__getobj__.dup)
  end

  def initialize_clone(obj)
    __setobj__(obj.__getobj__.clone)
  end
end
