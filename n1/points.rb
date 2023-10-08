
class Points
  def initialize(params = {})
    @p = params.dig(:p)
    @a = params.dig(:a)
    @b = params.dig(:b)
    @zero = {x: :none, y: :none, status: :zero}
    # @methods = Methods.new(debug_mode: params.dig(:debug_mode).to_sym)
  end

  def sum(p, q)
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
    r[:y] = (q[:y] + m * (r[:x] - q[:x])).pow(1, @p)
    r[:status] = :ok
    return inverse2(r, @p)
  end

  def mult(p, n)
    res = p

    (n-1).times do 
      res = sum(res, p)
    end

    res
  end

  private

  def mult2(p, n)
    result = @zero

    while n > 0
      result = sum(p,p) if n % 2 == 1
      p = sum(p,p)
      n = n / 2
    end

    sum(p,p)
  end

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

  def inverse2(a, p)
    a[:y] = p - a[:y]
    return a
  end

  def bits(n)
    while n > 0
      yield n & 1
      n >>= 1
    end
  end
  
  def double_and_add(n, x)

    result = 0
    addend = x
  
    bits(n).each do |bit|
      if bit == 1
        result += addend
      end
      addend *= 2
    end
  
    return result
  end

end
