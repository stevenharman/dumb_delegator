require "dumb_delegator/version"

class DumbDelegator < BasicObject
  (BasicObject.instance_methods - [:equal?, :__id__, :__send__, :method_missing]).each do |method|
    undef_method method
  end

  kernel = ::Kernel.dup
  (kernel.instance_methods - [:dup, :clone]).each do |method|
    kernel.__send__ :undef_method, method
  end
  include kernel

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
