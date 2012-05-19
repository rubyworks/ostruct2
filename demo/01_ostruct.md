# OpenStruct

The constructor can take a priming hash.

    o = OpenStruct.new(:a=>1,:b=>2)
    o.a  #=> 1
    o.b  #=> 2

It can also take a default procedure, just like an Hash.

    o = OpenStruct.new{ |h,k| h[k] = {} }
    o.a  #=> {}

Common usage of an OpenStruct is via the missing method dynamic calls.
An entry can be made by making an assignment and read back via the
same method call.

    o = OpenStruct.new
    o.a = 1
    o.a  #=> 1

Key existence can also be checked by adding a question mark.

    o.a?  #=> true

OpenStruct "circa 2" has a CRUDified design. There are only a few primary
methods that handle access to the underlying table and all other methods
route through these. Primarily they are `#read!`, `#store!`, `#delete!`
as well as `#key?` and `#keys!`.

    o = OpenStruct.new
    o.store!(:a, 1)
    o.read!(:a)  #=> 1
    o.key?(:a)   #=> true
    o.keys!      #=> [:a]
    o.delete!(:a)
    o.empty?     #=> true

OpenStruct offers a number of methods to access the underlying table.
Each of these ends in a exlimation mark, and include `#fetch!`, `#update!`, 
and `merge!`.

    o = OpenStruct.new
    o.update!(:a=>1, :b=>2)
    o.fetch!(:a)  #=> 1

Note that `#merge!` is akin to `Hash#merge`, not `Hash#merge!` --it does not
act in-place.

    o = OpenStruct.new
    x = o.merge!(:a=>1, :b=>2)
    o.a  #=> nil
    x.a  #=> 1

OpenStruct also supports Hash-like read and write operators, #[] and #[]=.

    o = OpenStruct.new
    o[:a] = 1
    o[:a]  #=> 1
    o.a    #=> 1

The OpenStruct object can be converted to a simple Hash, via `#to_h`.

    o = OpenStruct.new(:a=>1,:b=>2)
    o.to_h  #=> {:a=>1, :b=>2}

Iteration can be achieved with `#each!`.

    o = OpenStruct.new(:a=>1,:b=>2)
    a = {}
    o.each! do |k,v|
      a[k] = v
    end
    a  #=> {:a=>1, :b=>2}

Currently all Enumerable methods will work if suffixed with an exclemation mark. But they operate
directly on the underlying Hash rather than at the level of the "CRUDified" OpenStruct itself.

    o = OpenStruct.new(:a=>1,:b=>2)
    a = o.map!{ |k,v| [k,v] }
    a  #=> [[:a,1], [:b,2]]

In most cases this will work fine. But it may cause some minor discrepencies in how Enumerable 
methods work presently and how ultimatley they should work. A fix is a bit tricky so this is an
endeavor left a future release. In the rare cases where it does matters, proper enumeratorion
can be assured by calling `#to_enum` first.

    o = OpenStruct.new(:a=>1,:b=>2)
    a = {}
    o.to_enum.each do |k,v|
      a[k] = v
    end
    a  #=> {:a=>1, :b=>2}
 
OpenStruct also has a unique method called `#key!` that is used to check for an key entry,
and raise a KeyError if it not found.

    o = OpenStruct.new
    expect KeyError do
      o.key!(:x)
    end

Lastly, OpenStruct has a convenient feature for creating cascading OpenStructs.

    o = OpenStruct.cascade
    o.x.a = 1
    o.x.a  #=> 1
    OpenStruct.assert === o.a

