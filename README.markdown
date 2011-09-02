quiescent
=========

This is a very simple mixin to support quiescing constants, which we call "quiescents" in Ruby.  You may assign a value to a quiescing constant once during the execution of the program; however, a quiescing constant's value is fixed after the first time it is read.  Quiescing constants may have default values (specified either as explicit values or argumentless blocks to compute that value) that take effect if they are not explicitly assigned to before their first use.

If you like the convenience of constants but might need to defer giving them values, you'll like quiescents.  If you like single-assignment variables in languages like Prolog, you'll like quiescents.  If you [suspect that write-once values are far more common than most people admit](http://web.willbenton.com/research/vmcai-2011), you'll like quiescents.

Here's a simple example:

```ruby
require 'quiescent'

class Foo
  include Quiescent
  
  # This declares a constant named PostCode that 
  # quiesces to a default value of 53706 unless 
  # another is provided before the first time it
  # is read
  quiescent :PostCode, 53706
  
  # Let's assume that the awesome features are off
  # by default.
  quiescent :EnableTotallyAwesomeFeature, false
  quiescent :EnableSlightlyLessAwesomeFeature, false
  
  # This declares a constant named LazyThrees that 
  # quiesces to a list of all natural numbers less than
  # 100 that are divisible by three, as calculated
  # in the block, unless another value is provided. 
  # The block argument will execute at most once.
  quiescent :LazyThrees do
    (1..100).to_a.select {|x| x % 3 == 0}
  end
  
  # In this method, we'll see how to force quiescents
  # to quiesce by giving them values and reading their
  # values.
  def self.setup
    # We only want to do this once
    return if @setup_done
    @setup_done = true
    
    puts "The postal code is #{Foo::PostCode}"
    
    # You can provide non-default values with the
    # quiesce method...
    Foo.quiesce(:EnableTotallyAwesomeFeature, "sometimes")
    
    # ...or by using a special CONSTNAME= method, which
    # will be intercepted by method_missing.
    Foo.EnableSlightlyLessAwesomeFeature = true
    
    # Note that this only works for names corresponding
    # to declared quiescing constants...
    begin
      Foo.EnableCrummyFeature = true 
    rescue Exception
      puts("whoa, failure in aisle 47")
    end

    # ...and only once for each quiescing constant.
    begin
      Foo.EnableSlightlyLessAwesomeFeature = false
    rescue Exception
      puts("nice try, pal")
    end
  end
end
```

Potential gotchas
-----------------

Because of how constant resolution works in Ruby, we don't have a way to support quiescents whose names are identical to constants declared in the global namespace.  If you try and declare one, for example, `Foo::Kernel`, you'll get the toplevel `Kernel` when you try to access `Foo::Kernel`, along with the following message:

    warning: toplevel constant Kernel referenced by Foo::Kernel

`Quiescent` adds `const_missing` and `method_missing` methods to classes that mix it in.  These should play nicely with preexisting implementations of these (although these interactions are not exhaustively tested); however, classes that provide their own implementations of these methods should do so with care.  Please report any problematic interactions with your own code.

Contributing to quiescent
-------------------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2011 Red Hat, Inc. See LICENSE.txt for
further details.

