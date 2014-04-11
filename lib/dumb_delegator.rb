require 'set'
require 'dumb_delegator/version'

# monkey patch #leaf_methods and #wrapper_methods
class Object
  def leaf_methods
    methods - self.class.superclass.instance_methods
  end
  def wrapper_methods
    []
  end
end

class Module
  def ===(arg)
    arg.kind_of?(self)
  end
end

class DumbDelegator < ::BasicObject
  (::BasicObject.instance_methods - [:equal?, :__id__, :__send__, :method_missing]).each do |method|
    undef_method method
  end

  kernel = ::Kernel.dup
  (kernel.instance_methods - [:dup, :clone, :respond_to?, :methods]).each do |method|
    kernel.__send__ :undef_method, method
  end
  include kernel
  
  alias_method :orig_methods, :methods

  def initialize(target)
    __setobj__(target)
  end
  
  def methods( regular = true )
    orig_methods( regular ) + __getobj__.methods( regular )
  end
  
  def leaf_methods
    (methods - ::DumbDelegator.instance_methods) - __getobj__.class.superclass.instance_methods
  end

  def wrapper_methods
    (methods - ::DumbDelegator.instance_methods) - __getobj__.class.instance_methods
  end

  def respond_to?(method, include_all=false)
    __getobj__.respond_to?(method) || super
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
    raise ::ArgumentError, 'Delegation to self is not allowed.' if obj.__id__ == __id__
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
