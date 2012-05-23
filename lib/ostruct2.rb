# OpenStruct2 is better OpenStruct class.
#
# To demonstrate the weakness of the original OpenStruct, try this IRB session:
#
#   irb(main):001:0> o = OpenStruct.new
#   => #<OpenStruct>
#   irb(main):002:0> o.display = "Hello, World!"
#   => "Hello, World!"
#   irb(main):003:0> o.display
#   #<OpenStruct display="Hello, World!">=> nil
#
# This new OpenStruct class allows *almost* any member name to be used.
# The only exceptions are methods starting with double underscores,
# such as `__id__` and `__send__`, and a few neccessary public
# methods: `clone`, `dup`, `freeze`, `hash`, `to_enum`, `to_h`,
# `to_s` and `inspect`, as well as `instance_eval` and `instance_exec`.
#
# Also note that `empty`, `eql`, `equal` and `frozen` can be used as members
# but the key-check shorthand of using `?`-methods cannot be used since they
# have special definitions.
#
# To offset the loss of most methods, OpenStruct provides numerous
# bang-methods which can be used to manipulate the data, e.g. `#each!`.
# Currently most bang-methods route directly to the underlying hash table,
# so developers should keep that in mind when using this feature. A future
# version may add an intermediate interface to always ensure proper "CRUD",
# functonality but in the vast majority of cases it will make no difference,
# so it is left for later consideration.
#
# This improved version of OpenStruct also has no issues with being cloned
# since it does not depend on singleton methods to work. But singleton methods
# are used to help boost performance. But instead of always creating singleton
# methods, it only creates them on the first attempt to use them.
#
class OpenStruct2 < BasicObject

  class << self
    #
    # Create autovivified OpenStruct.
    #
    # @example
    #   o = OpenStruct2.renew
    #   o.a  #=> #<OpenStruct2: {}>
    #
    def auto(data=nil)
      leet = lambda{ |h,k| new(&leet) }
      new(&leet)
    end

    #
    # Another name for #auto method.
    #
    # TODO: Still wondering waht the best name is for this.
    #
    alias :renew :auto

    #
    # Create a nested OpenStruct, such that all sub-hashes
    # added to the table also become OpenStruct objects.
    #
    def nested(data=nil)
      o = new
      o.nested!(true)
      o.update!(data) if data
      o
    end

    #
    # Shorter name for `nested`.
    #
    alias :nest :nested

    #
    # Constructor that is both autovivified and nested.
    #
    def cascade(data=nil)
      o = renew
      o.nested!(true)
      o.update!(data) if data
      o
    end

  private

    def const_missing(name)
      ::Object.const_get(name)
    end
  end

  #
  # Initialize new instance of OpenStruct.
  #
  # @param [Hash] data
  #
  def initialize(data=nil, &block)
    @table = ::Hash.new(&block)
    update!(data || {})
  end

  #
  # Because there is no means of getting the class via a BasicObject instance,
  # we define such a method manually.
  #
  def __class__
    OpenStruct2
  end

  #
  # Duplicate underlying table when OpenStruct is duplicated or cloned.
  #
  # @param [OpenStruct] original
  #
  def initialize_copy(original)
    super
    @table = @table.dup
  end

  #
  # Dispatch unrecognized member calls.
  #
  def method_missing(sym, *args, &blk)
    str  = sym.to_s
    type = str[-1,1]
    name = str.chomp('=').chomp('!').chomp('?')

    case type
    when '!'
      # TODO: Probably should have an indirect interface to ensure proper
      #       functonariluiy in all cases.
      @table.public_send(name, *args, &blk)
    when '='
      new_ostruct_member(name)
      store!(name, args.first)
    when '?'
      new_ostruct_member(name)
      key?(name)
    else
      new_ostruct_member(name)
      read!(name)
    end
  end

  #
  # Get/set nested flag.
  #
  def nested!(boolean=nil)
    if boolean.nil?
      @nested
    else
      @nested = !!boolean
    end
  end

  #
  # CRUD method for listing all keys.
  #
  def keys!
    @table.keys
  end

  #
  # Also a CRUD method like #read!, but for checking for the existence of a key.
  #
  def key?(key)
    @table.key?(key.to_sym)
  end

  #
  # The CRUD method for read.
  #
  def read!(key)
    @table[key.to_sym]
  end

  #
  # The CRUD method for create and update.
  #
  def store!(key, value)
    if @nested && Hash === value  # value.respond_to?(:to_hash)
      value = OpenStruct2.new(value)
    end

    #new_ostruct_member(key)  # this is here only for speed bump

    @table[key.to_sym] = value
  end

  #
  # The CRUD method for destroy.
  #
  def delete!(key)
    @table.delete(key.to_sym)
  end

  #
  # Same as `#delete!`. This method provides compatibility
  # with the original OpenStruct class.
  #
  # @deprecated Use `#delete!` method instead.
  #
  def delete_field(key)
    @table.delete(key.to_sym)
  end

  #
  # Like #read but will raise a KeyError if key is not found.
  #
  def fetch!(key)
    key!(key)
    read!(key)
  end

  #
  # If key is not present raise a KeyError.
  #
  # @param [#to_sym] key
  #
  # @raise [KeyError] If key is not present.
  #
  # @return key
  #
  def key!(key)
    return key if key?(key)
    ::Kernel.raise ::KeyError, ("key not found: %s" % [key.inspect])
  end

  #
  # Alias for `#read!`.
  #
  # @param [#to_sym] key
  #
  # @return [Object]
  #
  def [](key)
    read!(key)
  end

  #
  # Alias for `#store!`.
  #
  # @param [#to_sym] key
  #
  # @param [Object] value
  #
  # @return value.
  #
  def []=(key, value)
    store!(key, value)
  end

  #
  # CRUDified each.
  #
  # @return nothing
  #
  def each!
    @table.each_key do |key|
      yield(key, read!(key))
    end
  end

  #
  def map!(&block)
    to_enum.map(&block)
  end

  #
  # CRUDified update method.
  #
  # @return [self]
  #
  def update!(other)
    other.each do |k,v|
      store!(k,v)
    end
    self
  end

  #
  # Merge this OpenStruct with another OpenStruct or Hash object
  # returning a new OpenStruct instance.
  #
  # IMPORTANT! This method does not act in-place like `Hash#merge!`,
  # rather it works like `Hash#merge`.
  #
  # @return [OpenStruct]
  #
  def merge!(other)
    o = dup
    other.each do |k,v|
      o.store!(k,v)
    end
    o
  end

  #
  # Inspect OpenStruct object.
  #
  # @return [String]
  #
  def inspect
    "#<#{__class__}: #{@table.inspect}>"
  end

  alias :to_s :inspect

  #
  # Get a duplicate of the underlying table.
  #
  # @return [Hash]
  #
  def to_h
    @table.dup
  end

  # TODO: Should OpenStruct2 support #to_hash ?
  #alias :to_hash :to_h

  #
  # Create an enumerator based on `#each!`.
  #
  # @return [Enumerator]
  #
  def to_enum
    ::Enumerator.new(self, :each!)
  end

  #
  # Duplicate OpenStruct object.
  #
  # @return [OpenStruct] Duplicate instance.
  #
  def dup
    __class__.new(@table, &@table.default_proc)
  end

  alias :clone :dup

  #
  # Hash number.
  #
  def hash
    @table.hash
  end

  #
  # Freeze OpenStruct instance.
  #
  def freeze
    @table.freeze
  end

  #
  # Is the OpenStruct instance frozen?
  #
  # @return [Boolean]
  #
  def frozen?
    @table.frozen?
  end

  #
  # Is the OpenStruct void of entries?
  #
  def empty?
    @table.empty?
  end

  #
  # Two OpenStructs are equal if they are the same class and their
  # underlying tables are equal.
  #
  def eql?(other)
    return false unless(other.kind_of?(__class__))
    return @table == other.table #to_h
  end

  #
  # Two OpenStructs are equal if they are the same class and their
  # underlying tables are equal.
  #
  # TODO: Why not equal for other hash types, e.g. via #to_h?
  #
  def ==(other)
    return false unless(other.kind_of?(__class__))
    return @table == other.table #to_h
  end

protected

  def table
    @table
  end

  def new_ostruct_member(name)
    name = name.to_sym
    # TODO: Check `#respond_to?` is needed? And if so how to do this in BasicObject?
    #return name if self.respond_to?(name)
    (class << self; self; end).class_eval do
      define_method(name) { read!(name) }
      define_method("#{name}?") { key?(name) }
      define_method("#{name}=") { |value| store!(name, value) }
    end
    name
  end

end
