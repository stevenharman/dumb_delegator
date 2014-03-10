require "spec_helper"

describe DumbDelegator do
  let(:target) { double }
  subject { described_class.new(target) }

  it "delegates to the target object" do
    expect(target).to receive(:foo)
    subject.foo
  end

  it "delegates to the target object with arguments" do
    expect(target).to receive(:foo).with(:bar)

    subject.foo(:bar)
  end

  it "delegates to the target object with a block" do
    bar_block = proc { "bar" }
    expect(target).to receive(:foo) { |&block| expect(block).to eq(bar_block) }

    subject.foo(&bar_block)
  end

  it "does not delegate if the target does not respond_to? the message" do
    allow(target).to receive(:foo)
    allow(target).to receive(:respond_to?).with(:foo).and_return(false)

    expect {
      subject.foo
    }.to raise_error(NoMethodError)
  end

  it "responds to methods defined by child classes that add behavior" do
    expect(target).to receive(:foo).never
    def subject.foo
      "bar"
    end

    subject.foo
  end

  it "delegates methods defined on Object" do
    expect(target).to receive(:class)
    subject.class
  end

  it "delegates is_a?" do
    expect(target).to receive(:is_a?)
    subject.is_a?
  end

  it "delegates methods defined on Kernel" do
    expect(target).to receive(:print)
    subject.print
  end

  it "delegates !" do
    expect(target).to receive(:!)
    !subject
  end

  it "delegates !=" do
    expect(target).to receive(:!=)
    subject != 1
  end

  it "delegates ==" do
    expect(target).to receive(:==)
    subject == 1
  end

  it "delegates ==" do
    expect(target).to receive(:==)
    subject == 1
  end

  it "delegates instance_eval" do
    expect(target).to receive(:instance_eval)
    subject.instance_eval { true }
  end

  it "delegates instance_exec" do
    expect(target).to receive(:instance_exec)
    subject.instance_exec { true }
  end

  describe "#dup" do
    it "returns a shallow of itself, the delegator (not the underlying object)", :objectspace => true do
      dupped = subject.dup

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include dupped.__id__
    end
  end

  describe "#clone" do
    it "returns a shallow of itself, the delegator (not the underlying object)", :objectspace => true do
      cloned = subject.clone

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include cloned.__id__
    end
  end

  describe "marshaling" do
    let(:target) { Object.new }

    it "marshals and unmarshals itself, the delegator (not the underlying object)", :objectspace => true do
      marshaled = Marshal.dump(subject)
      unmarshaled = Marshal.load(marshaled)

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include unmarshaled.__id__
    end
  end

  describe "#respond_to?" do
    [:equal?, :__id__, :__send__, :dup, :clone, :__getobj__, :__setobj__, :marshal_dump, :marshal_load, :respond_to?].each do |method|
      it "responds to #{method}" do
        expect(subject.respond_to?(method)).to be_true
      end
    end

    context "subclasses of DumbDelegator" do
      subject { Class.new(DumbDelegator) { def foobar; end }.new([]) }

      it "respond to methods defined on the subclass" do
        expect(subject.respond_to?(:foobar)).to be_true
      end
    end
  end

  describe "#__getobj__" do
    it "returns the target object" do
      expect(subject.__getobj__).to equal target
    end
  end

  describe "#__setobj__" do
    it "resets the target object to a different object" do
      expect(target).to receive(:foo).never

      new_target = double
      expect(new_target).to receive(:foo)

      subject.__setobj__(new_target)
      subject.foo
    end
  end
end
