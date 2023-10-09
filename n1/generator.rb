require './points.rb'
# require './graph.rb'


class Generator
  def initialize(params = {})
    @debug_mode = params.dig(:debug_mode).to_sym
    @filename = params.dig(:filename)
    
    @p = params[:data].dig(:p).to_i
    @b = params[:data].dig(:b).to_i
    @r = params[:data].dig(:r).to_i
    @q = params[:data].dig(:q)

    @curve = Points.new(a: 0, b: @b, p: @p)
    # @graph = Graph.new(@filename)
  end

  def start
    puts "\n[GEN] generating all points" if @debug_mode == :all

    arr = [@q]

    # pp @r
    @r.times do
      arr << @curve.sum(arr[-1], @q)
    end

    if @debug_mode == :all
      # puts arr
      puts "\n[GEN] All points generated"
      puts "\tPoints total count: #{arr.uniq.size}"
      puts "\tGroup size: #{@r}"
    end

    arr
  end

  def to_file(arr)
    # filename = 'coordinates.txt'
    puts "\n[GEN] Writing points to #{@filename}" if @debug_mode == :all

    File.delete(@filename.to_s) if File.exist?(@filename.to_s)

    File.open(@filename, "w") do |file|
      arr.uniq.each do |point|
        file.puts "#{point[:x]} #{point[:y]}" if point[:status] != :zero
      end
    end

    puts "\n[GEN] All points (exept zero one) were written to #{@filename}"
  end

  # def show
  #   picture = @graph.make_graph
  #   puts "\n[GEN] Find graph in #{picture}" if @debug_mode == :all
  # end
end