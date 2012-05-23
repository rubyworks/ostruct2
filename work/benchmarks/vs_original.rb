require 'benchmark'
require 'ostruct'
require 'ostruct2'

class OpenStructBenchmarks

  def initialize(num)
    @num = num
  end

  attr :num

  def bench_new(klass, data)
    num.times do
      klass.new(data)
    end
  end

  def bench_read(klass, data)
    o = klass.new(data)
    num.times do
      o.__send__(:table).keys.each do |k|
        eval "o.#{k}"
      end
    end
  end

  def bench_write(klass)
    o = klass.new
    num.times do
      (:a..:z).each do |k|
        eval "o.#{k}='foo'"
      end
    end
  end

end

bm = OpenStructBenchmarks.new(20000)

Benchmark.bmbm do |x|
  puts "NEW"
  data = {:a=>1, :b=>2, :c=>{:x=>9}}
  x.report("ostruct")  { bm.bench_new(OpenStruct,  data) }
  x.report("ostruct2") { bm.bench_new(OpenStruct2, data) }
end

puts

Benchmark.bmbm do |x|
  puts "READ"
  data = {:a=>1, :b=>2, :c=>{:x=>9}}
  x.report("ostruct")  { bm.bench_read(OpenStruct,  data) }
  x.report("ostruct2") { bm.bench_read(OpenStruct2, data) }
end

puts

Benchmark.bmbm do |x|
  puts "WRITE"
  x.report("ostruct")  { bm.bench_write(OpenStruct)  }
  x.report("ostruct2") { bm.bench_write(OpenStruct2) }
end

