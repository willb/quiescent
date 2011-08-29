require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quiescent do
  it "successfully creates quiescents with default arguments" do
    classid = gen_id("Foo")
    k = Klass(classid, "include Quiescent", QConst("Bar", "12345"))
    eval(k.to_s)
    Kernel.const_get(classid)::Bar.should == 12345
  end

  it "successfully creates multiple quiescents with default arguments in a single class" do
    classid = gen_id("Foo")
    k = Klass(classid, "include Quiescent", QConst("Fred", ":a"), QConst("Barney", "54321"))
    eval(k.to_s)
    Kernel.const_get(classid)::Fred.should == :a
    Kernel.const_get(classid)::Barney.should == 54321
  end

  it "allows assigning alternate values to quiescents with default arguments" do
    classid = gen_id("Foo")
    k = Klass(classid, "include Quiescent", QConst("Bar", "12345"))
    eval(k.to_s)
    Kernel.const_get(classid).Bar = 54321
    Kernel.const_get(classid)::Bar.should == 54321
  end

  it "allows assigning alternate values to quiescents with default arguments only once" do
    classid = gen_id("Foo")
    k = Klass(classid, "include Quiescent", QConst("Bar", "12345"))
    eval(k.to_s)
    Kernel.const_get(classid).Bar = 54321
    lambda {Kernel.const_get(classid).Bar = 12345}.should raise_error
    Kernel.const_get(classid)::Bar.should == 54321    
  end

  it "successfully creates quiescents with block arguments" do
    classid = gen_id("Foo")
    k = Klass(classid, "include Quiescent", QConst("Bar", Do("12345")))
    eval(k.to_s)
    Kernel.const_get(classid)::Bar.should == 12345
  end
  
  it "only evaluates quiescent block arguments once" do
    $foo = Object.new
    $foo.should_receive(:hash).once
    classid = gen_id("Foo")
    k = Klass(classid, "include Quiescent", QConst("Bar", Do("$foo.hash; 12345")))
    eval(k.to_s)
    Kernel.const_get(classid)::Bar.should == 12345
    Kernel.const_get(classid)::Bar
  end

  it "only adds quiescents to the classes in which they are declared" do
    classid1 = gen_id("Fred")
    classid2 = gen_id("Barney")
    [Klass(classid1, "include Quiescent", QConst("Bar", "12345")),
     Klass(classid2, "include Quiescent", QConst("Foo", "54321"))].each do |k|
       eval(k.to_s)
    end
    
    Kernel.const_get(classid1)::Bar.should == 12345
    Kernel.const_get(classid2)::Foo.should == 54321

    lambda {Kernel.const_get(classid1)::Foo}.should raise_error
    lambda {Kernel.const_get(classid2)::Bar}.should raise_error
  end

end
