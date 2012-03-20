require "dumb_delegator/version"

class DumbDelegator < BasicObject
  (BasicObject.instance_methods - [:equal?, :__id__, :__send__, :method_missing]).each do |method|
    undef_method method
  end

  def initialize(target)
    __setobj__(target)
  end

  def method_missing(method, *args, &block)
    if @__dumb_target__.respond_to?(method)
      @__dumb_target__.__send__(method, *args, &block)
    else
      super
    end
  end

  def __getobj__
    @__dumb_target__
  end

  def __setobj__(obj)
    @__dumb_target__ = obj
  end
end
