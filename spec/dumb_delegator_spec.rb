require 'spec_helper'

describe DumbDelegator do
  subject(:dummy) { described_class.new(target) }
  let(:target) { double }

  it 'delegates to the target object' do
    expect(target).to receive(:foo)
    dummy.foo
  end

  it 'delegates to the target object with arguments' do
    expect(target).to receive(:foo).with(:bar)

    dummy.foo(:bar)
  end

  it 'delegates to the target object with a block' do
    bar_block = proc { 'bar' }
    expect(target).to receive(:foo) { |&block| expect(block).to eq(bar_block) }

    dummy.foo(&bar_block)
  end

  it 'does not delegate if the target does not respond_to? the message' do
    allow(target).to receive(:foo)
    allow(target).to receive(:respond_to?).with(:foo).and_return(false)

    expect {
      dummy.foo
    }.to raise_error(NoMethodError)
  end

  it 'responds to methods defined by child classes that add behavior' do
    expect(target).to receive(:foo).never
    def dummy.foo
      'bar'
    end

    dummy.foo
  end

  it 'delegates methods defined on Object' do
    expect(target).to receive(:class)
    dummy.class
  end

  it 'delegates is_a?' do
    expect(target).to receive(:is_a?)
    dummy.is_a?
  end

  it 'delegates methods defined on Kernel' do
    expect(target).to receive(:print)
    dummy.print
  end

  it 'delegates !' do
    expect(target).to receive(:!)
    !dummy
  end

  it 'delegates !=' do
    expect(target).to receive(:!=)
    dummy != 1
  end

  it 'delegates ==' do
    expect(target).to receive(:==)
    dummy == 1
  end

  it 'delegates ==' do
    expect(target).to receive(:==)
    dummy == 1
  end

  it 'delegates instance_eval' do
    expect(target).to receive(:instance_eval)
    dummy.instance_eval { true }
  end

  it 'delegates instance_exec' do
    expect(target).to receive(:instance_exec)
    dummy.instance_exec { true }
  end

  it 'does not interfere with constant lookup' do
    dummy = Dummy.new(target)

    expect(dummy.foo).to eq('baz')
  end

  describe '#dup' do
    it 'returns a shallow of itself, the delegator (not the underlying object)', :objectspace => true do
      dupped = dummy.dup

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include dupped.__id__
    end
  end

  describe '#clone' do
    it 'returns a shallow of itself, the delegator (not the underlying object)', :objectspace => true do
      cloned = dummy.clone

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include cloned.__id__
    end
  end

  describe 'marshaling' do
    let(:target) { Object.new }

    it 'marshals and unmarshals itself, the delegator (not the underlying object)', :objectspace => true do
      marshaled = Marshal.dump(dummy)
      unmarshaled = Marshal.load(marshaled)

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include unmarshaled.__id__
    end
  end

  describe '#respond_to?' do
    [:equal?, :__id__, :__send__, :dup, :clone, :__getobj__, :__setobj__, :marshal_dump, :marshal_load, :respond_to?].each do |method|
      it "responds to #{method}" do
        expect(dummy.respond_to?(method)).to be true
      end
    end

    context 'subclasses of DumbDelegator' do
      subject(:dummy) { Class.new(DumbDelegator) { def foobar; end }.new([]) }

      it 'respond to methods defined on the subclass' do
        expect(dummy.respond_to?(:foobar)).to be true
      end
    end
  end

  describe '#__getobj__' do
    it 'returns the target object' do
      expect(dummy.__getobj__).to equal target
    end
  end

  describe '#__setobj__' do
    it 'resets the target object to a different object' do
      expect(target).to receive(:foo).never

      new_target = double
      expect(new_target).to receive(:foo)

      dummy.__setobj__(new_target)
      dummy.foo
    end

    it 'cannot delegate to itself' do
      expect {
        dummy.__setobj__(dummy)
        dummy.foo
      }.to raise_error(ArgumentError, 'Delegation to self is not allowed.')
    end
  end
end

class DummyForConstLookup
  def self.foo
    'baz'
  end
end

class Dummy < DumbDelegator
  def foo
    DummyForConstLookup.foo
  end
end
