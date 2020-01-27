RSpec.describe DumbDelegator do
  subject(:dummy) { Wrapper.new(target) }
  let(:target) { Target.new }

  class Wrapper < DumbDelegator
    def wrapper_method
      "Method only on wrapper."
    end

    def common_method
      ["Method on wrapper.", super].join(" ")
    end
  end

  class Target
    def common_method
      "Method on target."
    end

    def target_method
      "Method only on target."
    end

    def query(*args)
      "queried with #{args}"
    end

    def with_block(&block)
      block.call
    end
  end

  it "delegates to the target object" do
    expect(dummy.target_method).to eq("Method only on target.")
  end

  it "delegates to the target object with arguments" do
    result = dummy.query("some_key", 42)

    expect(result).to eq(%(queried with ["some_key", 42]))
  end

  it "delegates to the target object with a block" do
    result = dummy.with_block { "block called!" }

    expect(result).to eq("block called!")
  end

  it "errors if the method is not defined on the wrapper nor the target" do
    expect {
      dummy.no_such_method
    }.to raise_error(NoMethodError)
  end

  it "responds to methods defined by child classes" do
    expect(dummy.wrapper_method).to eq("Method only on wrapper.")
  end

  it "responds to methods defined by child classes, and can super up to target" do
    expect(dummy.common_method).to eq("Method on wrapper. Method on target.")
  end

  it "delegates methods defined on Object" do
    expect(dummy.class).to eq(Target)
  end

  it "delegates methods defined on Kernel" do
    expect(target).to receive(:nil?)
    dummy.nil?
  end

  it "delegates bang (!) operator" do
    allow(target).to receive(:!) { "bang!" }
    expect(!dummy).to eq("bang!")
  end

  it "delegates object inequivalence" do
    allow(target).to receive(:!=).and_call_original

    expect(dummy != target).to be false
  end

  it "delegates object equivalence" do
    aggregate_failures do
      expect(dummy).to eql(target)
      expect(dummy == target).to be true
    end
  end

  it "delegates #===" do
    expect(dummy === target).to be true
  end

  it "delegates class checks" do
    aggregate_failures do
      expect(dummy.is_a?(Target)).to be(true)
      expect(dummy.kind_of?(Target)).to be(true) # rubocop:disable Style/ClassCheck
      expect(dummy.instance_of?(Target)).to be(true)
    end
  end

  it "does not delegate ::=== to the target's class" do
    aggregate_failures do
      expect(Target === dummy).to be false
      expect(DumbDelegator === dummy).to be true
    end
  end

  context "with a Module/Class's ::=== overridden via extension" do
    let(:target) { TargetWithTripleEqualExt.new }

    class TargetWithTripleEqualExt
      extend DumbDelegator::TripleEqualExt
    end

    it "delegates ::=== to the target's class" do
      aggregate_failures do
        expect(TargetWithTripleEqualExt === dummy).to be true
        expect(DumbDelegator === dummy).to be true
      end
    end
  end

  it "delegates instance_eval" do
    expect(target).to receive(:instance_eval)
    dummy.instance_eval { true }
  end

  it "delegates instance_exec" do
    expect(target).to receive(:instance_exec)
    dummy.instance_exec { true }
  end

  describe "#dup" do
    it "returns a shallow of itself, the delegator (not the underlying object)", objectspace: true do
      dupped = dummy.dup

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include dupped.__id__
    end
  end

  describe "#clone" do
    it "returns a shallow of itself, the delegator (not the underlying object)", objectspace: true do
      cloned = dummy.clone

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include cloned.__id__
    end
  end

  describe "marshaling" do
    let(:target) { Object.new }

    it "marshals and unmarshals itself, the delegator (not the underlying object)", objectspace: true do
      marshaled = Marshal.dump(dummy)
      unmarshaled = Marshal.load(marshaled)

      expect(ObjectSpace.each_object(DumbDelegator).map(&:__id__)).to include unmarshaled.__id__
    end
  end

  describe "#respond_to?" do
    [:equal?, :__id__, :__send__, :dup, :clone, :__getobj__, :__setobj__, :marshal_dump, :marshal_load, :respond_to?].each do |method|
      it "responds to #{method}" do
        expect(dummy.respond_to?(method)).to be true
      end
    end

    context "subclasses of DumbDelegator" do
      it "respond to methods defined on the subclass" do
        expect(dummy).to respond_to(:target_method)
      end
    end
  end

  describe "#__getobj__" do
    it "returns the target object" do
      expect(dummy.__getobj__).to equal(target)
    end
  end

  describe "#__setobj__" do
    it "resets the target object to a different object" do
      new_target = Target.new.tap do |nt|
        def nt.a_new_thing
          true
        end
      end

      dummy.__setobj__(new_target)
      expect(dummy.a_new_thing).to be true
    end

    it "cannot delegate to itself" do
      expect {
        dummy.__setobj__(dummy)
        dummy.common_method
      }.to raise_error(ArgumentError, "Delegation to self is not allowed.")
    end
  end

  describe "introspection capabilities" do
    it "provides a human-friendly representation of the delegator and wrapped object" do
      expect(dummy.inspect).to match(/#<Wrapper:\w+ obj: .+Target.+>/)
    end

    it "reports methods defined on the target" do
      expect(dummy.methods).to include(:target_method, :common_method)
    end

    it "reports methods defined on the wrapper" do
      expect(dummy.methods).to include(:wrapper_method, :common_method)
    end

    it "looks up a named method on the target" do
      method = dummy.method(:target_method)
      aggregate_failures do
        expect(method).not_to be_nil
        expect(method.receiver).to eq(target)
      end
    end

    it "looks up a named method on the wrapper" do
      method = dummy.method(:wrapper_method)
      aggregate_failures do
        expect(method).not_to be_nil
        expect(method.receiver).to equal(dummy)
      end
    end
  end
end
