class Points
  def initialize(params = {})
    @p = params.dig(:p)
    @a = params.dig(:a)
    @b = params.dig(:b)
    @zero = { x: :none, y: :none, status: :zero }
  end

  def make_point(x, y, status)
    { x: x, y: y, status: status }
  end

  def sum1(p, q)
    r = {}

    return q if p[:status] == :zero
    return p if q[:status] == :zero

    return @zero if p[:x] == q[:x] && p[:y] != q[:y]

    if p[:x] != q[:x]
      m = ((p[:y] - q[:y]) * inverse(p[:x] - q[:x], @p)).pow(1, @p)
    elsif p[:x] == q[:x] && p[:y] == q[:y]
      m = ((3 * (p[:x].pow(2, @p)) + @a) * inverse(2 * p[:y], @p)).pow(1, @p) 
    end

    r[:x] = (m ** 2 - p[:x] - q[:x]).pow(1, @p)
    r[:y] = (m * (r[:x] - q[:x]) - q[:y]).pow(1, @p)
    r[:status] = :ok
    return r
  end

  def sum(p, q)
    r = {}

    return q if p[:status] == :zero
    return p if q[:status] == :zero

    if p[:x] != q[:x]
      m = ((p[:y] - q[:y]) * inverse(p[:x] - q[:x], @p))

      r[:x] = (m ** 2 - (p[:x] + q[:x])) % @p
      r[:y] = ((m * (p[:x] - r[:x])) - p[:y]) % @p
      r[:status] = :ok
    else
      if p[:y] == q[:y]
        m = ((3 * (p[:x] ** 2) + @a) * inverse(2 * p[:y], @p))
        
        r[:x] = (m ** 2 - 2 * p[:x]) % @p
        r[:y] = (m * (p[:x] - r[:x]) - p[:y]) % @p
        r[:status] = :ok
      else
        r = { x: :none, y: :none, status: :zero }
      end
    end
    # puts "alfa: #{m}"
    # puts "x3 = - #{p[:x]} - #{q[:x]} + #{m**2} = #{-p[:x]-q[:x]+m**2} mod 11"
    # puts "y3 = - #{p[:y]} + #{m} * (#{p[:x]} - #{r[:x]}) mod 11 = #{-p[:y]+m*(p[:x]-r[:x])} =#{r[:y]}"
    # puts "r: #{r}"
    return r
  end

  def mult_slow(p, n)
    return { x: :none, y: :none, status: :zero } if n == 0
    
    res = { x: :none, y: :none, status: :zero }
    
    if n < 0
      p = inverse2(p, @p)
    end

    (n.abs).times do 
      res = sum(res, p)
    end

    res
  end

  def inverse2(a, p)
    if a[:status] == :zero
      return a
    end

    return {x: a[:x], y: (p - a[:y]) % p, status: a[:status]}
  end

  def mult(p, n)
    return { x: :none, y: :none, status: :zero } if n == 0

    if n < 0
      p = inverse2(p, @p)
      n = n.abs
    end

    res = { x: :none, y: :none, status: :zero }
    temp_p = p.clone

    while !n.zero?
      res = sum(temp_p, res) if !n.even?
      temp_p = sum(temp_p, temp_p)
      n /= 2
    end

    return res
  end

  private

  def exea(a, b)
    s, old_s = 0, 1
    t, old_t = 1, 0
    r, old_r = b, a
  
    while r != 0
      quotient = old_r / r
      old_r, r = r, old_r - quotient * r
      old_s, s = s, old_s - quotient * s
      old_t, t = t, old_t - quotient * t
    end
  
    [old_r, old_s, old_t]
  end
  
  def inverse(n, p)
    gcd, x, y = exea(n, p)
    raise %{#{n} has no multiplicative inverse modulo #{p}} if gcd != 1
    x % p
  end

end
