require "spec_helper"

describe DumbDelegator do
  let(:target) { double }
  subject { described_class.new(target) }

  it "delegates to the target object" do
    target.should_receive(:foo)
    subject.foo
  end

  it "delegates to the target object with arguments" do
    target.should_receive(:foo).with(:bar)

    subject.foo(:bar)
  end

  it "delegates to the target object with a block" do
    bar_block = proc { "bar" }
    target.should_receive(:foo) { |&block| block.should == bar_block }

    subject.foo(&bar_block)
  end

  it "does not delegate if the target does not respond_to? the message" do
    target.stub(:foo)
    target.stub(:respond_to?).with(:foo).and_return(false)

    expect {
      subject.foo
    }.to raise_error(NoMethodError)
  end

  it "responds to methods defined by child classes that add behavior" do
    target.should_receive(:foo).never
    def subject.foo
      "bar"
    end

    subject.foo
  end

  it "delegates methods defined on Object" do
    target.should_receive(:class)
    subject.class
  end

  it "delegates methods defined on Kernel" do
    target.should_receive(:print)
    subject.print
  end

  describe "#__getobj__" do
    it "returns the target object" do
      subject.__getobj__.should equal target
    end
  end

  describe "#__setobj__" do
    it "resets the target object to a different object" do
      target.should_receive(:foo).never

      new_target = double
      new_target.should_receive(:foo)

      subject.__setobj__(new_target)
      subject.foo
    end
  end
end
