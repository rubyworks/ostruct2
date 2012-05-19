# A better OpenStruct class.
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
  def initialize(data=nil, &block)
    @table = ::Hash.new(&block)
    update!(data || {})
  end

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

  # CRUD method for listing all keys.
  def keys!
    @table.keys
  end

  # Also a CRUD method like #read!, but for checking for the existence of a key.
  def key?(key)
    @table.key?(key.to_sym)
  end

  # The CRUD method for read.
  def read!(key)
    @table[key.to_sym]
  end

  # The CRUD method for create and update.
  def store!(key, value)
    @table[key.to_sym] = value
  end

  # The CRUD method for destroy.
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
  def [](key)
    read!(key)
  end

  #
  def []=(key, value)
    store!(key, value)
  end

  # CRUDified each.
  def each!
    @table.each_key do |key|
      yield(key, read!(key))
    end
  end

  # CRUDified update method.
  def update!(other)
    other.each do |k,v|
      store!(k,v)
    end
  end

  #
  # IMPORTANT! This method does not act in-place like `Hash#merge!`,
  # rather it works like `Hash#merge`.
  #
  def merge!(other)
    # TODO: is there anyway to #dup a BasicObject subclass instance?
    o = ::OpenStruct.new(@table, &@table.default_proc)
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
  def to_h
    @table.dup
  end

  #
  def to_enum
    ::Enumerator.new(self, :each!)
  end

  #
  # If key is not present raise a KeyError.
  #
  def key!(key)
    return key if key?(key)
    ::Kernel.raise ::KeyError, ("key not found: %s" % [key.inspect])
  end

  #
  #
  #
  def inspect
    "#<OpenStruct: #{@table.inspect}>"
  end

end

