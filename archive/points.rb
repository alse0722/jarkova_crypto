require './methods.rb'

class Points
  def initialize(params = {})
    @debug_mode = params.dig(:debug_mode).to_sym
    @methods = Methods.new(debug_mode: 'all')
    @zero_point = {x: :inf, y: :inf, status: :zero}

    @p = params.dig(:p)
    @n = params.dig(:n)
    @b = params.dig(:b)
    @k = params.dig(:k)
    @r = params.dig(:r)
  end

  def is_zero(point)
    return point[:status] == :zero
  end

  def negate(point)
    point[:y] = @p - point[:y] if !is_zero(point)
  end

  def sum(point_a, point_b)
    return point_b if is_zero(point_a)
    return point_a if is_zero(point_b)

    if point_a[:x] != point_b[:x]
      l = (point_a[:y] - point_b[:y]) * @methods.inverse(point_a[:x] + point_b[:x], @p)
    elsif point_a[:y] == 0 && point_b[:y] == 0
      return @zero_point
    elsif
      l = (3 * point_a[:x] ** 2) * @methods.inverse(point_a[:y] * 2, @p)
    else
      return @zero_point
    end

    cx = (l ** 2 - point_a[:x] - point_b[:x] + @p) % @p
    cy = (l * (point_a[:x] - cx) - point_a[:y] + @p) % @p

    {x: cx, y: cy, status: :common}
  end

  def mul(point, scalar)
    result = @zero_point
  
    while scalar > 0
      if scalar % 2 == 1
        result = sum(result, point)
      end
  
      point = sum(point, point)
      scalar = scalar / 2
    end
  
    result
  end

end


@test = Points.new({debug_mode: 'all', p: 97})
a = {x: 21, y: 20}
b = {x: 86, y: 24}

pp @test.sum(a, b)