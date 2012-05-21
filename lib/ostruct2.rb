# A better OpenStruct class.
#
# This OpenStruct class allows almost any member name to be used.
# The only exceptions are methods starting with double underscores,
# e.g. `__id__`, and a few neccessary public methods: `hash`, `dup`,
# `to_enum`, `to_h` and `inspect`.
#
# To offset the loss of most methods, OpenStruct provides numerous
# bang-methods which can be used to manipulate the data, e.g. `#each!`.
#
# This improved version of OpenStruct also has no issues with being
# cloned or marshalled since it does not depend on singleton methods.
#
class OpenStruct < BasicObject

  class << self
    #
    # Create cascading OpenStruct.
    #
    def cascade(data=nil)
      leet = lambda{ |h,k| OpenStruct.new(&leet) }
      new(&leet)
    end

    # Is there a better name for #auto?
    #alias :autorenew :cascade

    # Original name for #cascade method.
    alias :auto :cascade
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
  # Dispatch unrecognized member calls.
  #
  def method_missing(sym, *args, &blk)
    str  = sym.to_s
    type = str[-1,1]
    name = str.chomp('=').chomp('!').chomp('?')

    case type
    when '='
      store!(name, args.first)
    when '!'
      @table.public_send(name, *args, &blk)
    when '?'
      key?(name)
    else
      read!(name)
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
    @table[key.to_sym] = value
  end

  #
  # The CRUD method for destroy.
  #
  def delete!(key)
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
  # Is the OpenStruct void of entries?
  #
  def empty?
    @table.empty?
  end

  #
  # Get a duplicate of the underlying table.
  #
  # @return [Hash]
  #
  def to_h
    @table.dup
  end

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
    ::OpenStruct.new(@table, &@table.default_proc)
  end

  #
  # Hash number.
  #
  def hash
    @table.hash
  end

  #
  # Inspect OpenStruct object.
  #
  # @return [String]
  #
  def inspect
    "#<OpenStruct: #{@table.inspect}>"
  end

end

