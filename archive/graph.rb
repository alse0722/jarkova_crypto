# require 'gruff'

class Graph

  def initialize(filename)
    @filename = filename
  end

  def make_graph
    plot_coordinates(read_coordinates(@filename))
  end

  private

  def read_coordinates(filename)
    coordinates = []
    File.foreach(filename) do |line|
      match_data = line.match(/:x=>(\d+),\s:y=>(\d+)/)
      next unless match_data
      x = match_data[1].to_i
      y = match_data[2].to_i
      coordinates << [x, y]
    end
    coordinates
  end
  
  def plot_coordinates(coordinates)
    g = Gruff::Line.new
    g.title = "Coordinates Graph"
  
    x_values = coordinates.map { |coord| coord[0] }
    y_values = coordinates.map { |coord| coord[1] }
  
    g.data('Coordinates', y_values, '#FF0000')
    g.labels = Hash[x_values.each_with_index.map { |x, index| [index, x.to_s] }]
  
    g.x_axis_label = 'X'
    g.y_axis_label = 'Y'
  
    g.write('coordinates_graph.png')
  end
end
