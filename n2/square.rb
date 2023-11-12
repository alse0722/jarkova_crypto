
require 'prime'

class Square
  def initialize
  end

  def call_saul(a, p)
    m = 0
    q = p - 1

    while q.even?
      q >>= 1
      m += 1
    end

    b = rand(0..p - 1)

    b = rand(0..p - 1) while legendre_symbol(b, p) != -1

    an, kn = [a], []
    ai = a

    loop do
      ki = 0
      ki += 1 while ai.pow((2**ki) * q, p).zero?

      break if ki.zero?

      kn.append(ki)
      ai = ai * b.pow((2 << (m - ki - 1)), p)
      an.append(ai)
    end

    rn = [an.last.pow((q + 1) / 2, p)]
    kn.each do |ki|
      rn.append(rn.last * inverse(b.pow((2 << (m - ki - 2)), p)) % p)
    end

    rn.last

    generated_square(a,p)
  end

  def call(a, p)
    generated_square(a, p)
  end

  private

  def gcd(x1, x2)
    x2.zero? ? x1 : gcd(x2, x1 % x2)
  end

  def gcd_extended(x1, x2)
    return x2, 0, 1 if x1.zero?

    div, x, y = gcd_extended(x2 % x1, x1)
    [div, y - (x2 / x1) * x, x]
  end

  def inverse(a, m)
    d, u, v = gcd_extended(a, m)
    if d != 1
      puts "Нет обратного у элемента a = #{a} в кольце вычетов по модулю #{m}"
      exit
    end
    u % m
  end

  def continued_fraction(a0, a1)
    return 'Знаменатель должен быть больше нуля!' if a1 <= 0

    qs = []
    while a1 != 0
      r = a0 % a1
      qs.append((a0 - r) / a1)
      a0 = a1
      a1 = r
    end
    qs
  end

  def successive_convergents(a0, a1)
    qs = [0, 0] + continued_fraction(a0, a1)
    big_ps = [0, 1]
    big_qs = [1, 0]

    (2...qs.length).each do |i|
      big_ps.append(big_ps[i - 1] * qs[i] + big_ps[i - 2])
      big_qs.append(big_qs[i - 1] * qs[i] + big_qs[i - 2])
    end

    [big_ps, big_qs]
  end

  def diophantine_equation(a, b, c, t)
    if gcd(a.abs, b.abs) == 1
      ps, qs = successive_convergents(a.abs, b.abs)
      x0 = qs[-2] * c
      y0 = ps[-2] * c

      if ps.length.odd?
        x0 *= -1
      else
        y0 *= -1
      end

      x0 *= -1 if a < 0
      y0 *= -1 if b < 0

      x0 += b * t
      y0 -= a * t

      return x0, y0
    end

    false
  end

  def generated_square(a, p)

    # puts "generated_square a = #{a}"
    if a == 0
      return 0
    end

    y = 0
    while y < p && (y ** 2) % p != a % p
      y = y + 1
      # puts "hui :#{y}"
    end
    
    return y
  end

  def factorize(n)
    factors = []
    p = 2

    loop do
      while n % p == 0 && n.positive?
        factors.append(p)
        n /= p
      end

      p += 1

      break if p > n / p
    end

    factors.append(n) if n > 1
    factors
  end

  def legendre_symbol(a, p)
    return legendre_symbol(a % p, p) if a >= p || a < 0
    return a if a.zero? || a == 1

    if a == 2
      return (p % 8 == 1 || p % 8 == 7) ? 1 : -1
    elsif a == p - 1
      return (p % 4 == 1) ? 1 : -1
    elsif !Prime.prime?(a)
      factors = factorize(a)
      product = 1

      factors.each { |pi| product *= legendre_symbol(pi, p) }
      return product
    else
      return (p % 2 == 0 || a % 2 == 0) ? legendre_symbol(p, a) : -1 * legendre_symbol(p, a)
    end
  end
end