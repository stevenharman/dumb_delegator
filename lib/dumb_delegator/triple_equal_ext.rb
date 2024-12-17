# frozen_string_literal: true

class DumbDelegator < ::BasicObject
  ##
  # This optional extension enables a Class/Module to support +case+ statements.
  #
  # Specifically, it monkey-patches a Class/Module's +:===+ method to check if the +other+ argument is an instance of the extended Class/Module.
  #
  # @example Extending a Class/Module to handle class equality for a DumbDelegator instance.
  #
  # target = MyAwesomeClass.new
  # dummy = DumbDelegator.new(target)
  #
  # MyAwesomeClass === dummy #=> false
  # DumbDelegator === dummy  #=> true
  #
  # MyAwesomeClass.extend(DumbDelegator::TripleEqualExt)
  #
  # MyAwesomeClass === dummy #=> true
  # DumbDelegator === dummy  #=> true
  module TripleEqualExt
    # Case equality for the extended Class/Module and then given +other+.
    #
    # @param other [Object] An instance of any Object
    #
    # @return [Boolean] If the +other+ is an instance of the Class/Module.
    def ===(other)
      super || other.is_a?(self)
    end
  end
end
