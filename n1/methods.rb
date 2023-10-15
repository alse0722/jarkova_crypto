require './points.rb'
require './generator.rb'

class Methods

  def initialize(params = {})
    @debug_mode = params.dig(:debug_mode).to_sym
    @points_debug_mode = params.dig(:points_debug_mode).to_sym
    @l = params.dig(:l).to_i
    @m = params.dig(:m).to_i
  end

  def step1
    p = gen_big_prime

    while (p % 6) != 1
      p = gen_big_prime
    end

    p
  end

  def step2(p = 0, d = 3)

    return {} if lezhandr2(-d, p) == -1

    u = gluchov_algo(p, -d)
    while u.pow(2, p) != p - d
      u = gluchov_algo(p, -d)
    end

    # puts "gluchov_algo(#{p}, #{-d}): #{u}"

    u_arr = [u]
    m_arr = [p]

    # pp "m_arr: #{m_arr}"
    # pp "u_arr: #{u_arr}"

    # puts "\n\twhile m_arr[-1] != 1"
    while m_arr[-1] != 1
      m_arr << (u_arr[-1] ** 2 + d) / m_arr[-1]
      # pp "new_m: #{(u_arr[-1] ** 2 + d) / m_arr[-1]}"
      u_arr << [u_arr[-1].pow(1, m_arr[-1]), m_arr[-1] - u_arr[-1].pow(1, m_arr[-1])].min
      # pp "m_arr: #{m_arr}"
      # pp "u_arr: #{u_arr}"
    end

    # puts "\nafter while"
    # pp "m_arr: #{m_arr}"
    # pp "u_arr: #{u_arr}"

    u_arr.delete(0)
    u_arr = u_arr.reverse()
    arh = reactualize(p)

    a_arr = [u_arr[0]]
    b_arr = [1]

    # puts "\nafter u_arr.delete(0)"
    # pp "a_arr: #{a_arr}"
    # pp "b_arr: #{b_arr}"
    # pp "u_arr: #{u_arr}"
    

    u_arr[1..-1].each do |u|
      divisor = a_arr[-1] ** 2 + d * b_arr[-1] ** 2
      devided_a = if (u * a_arr[-1] + d * b_arr[-1]) % divisor == 0
        (u * a_arr[-1] + d * b_arr[-1]) / divisor
      else
        ((-1) * u * a_arr[-1] + d * b_arr[-1]) / divisor
      end

      devided_b = if ((-1) * a_arr[-1] + u * b_arr[-1]) % divisor == 0
        ((-1) * a_arr[-1] + u * b_arr[-1]) / divisor
      else
        ((-1) * a_arr[-1] + (-1) * u * b_arr[-1]) / divisor
      end

      a_arr << devided_a
      b_arr << devided_b
    end

    {c: arh[0], d: arh[1]}
  end

  def step3(p, c, d)
    n = [c + (3 * d), c - (3 * d), 2 * c]
    n << n[0] * (-1)
    n << n[1] * (-1)
    n << n[2] * (-1)

    n = n.map {|e| e += p + 1}
    # puts n

    triplets = []

    n.each do |e|
      triplets << {k: 1, p: p, n: e, r: e} if miller_rabin_prime(e)
      triplets << {k: 2, p: p, n: e, r: e/2} if e % 2 == 0 && miller_rabin_prime(e/2)
      triplets << {k: 3, p: p, n: e, r: e/3} if e % 3 == 0 && miller_rabin_prime(e/3)
      triplets << {k: 6, p: p, n: e, r: e/6} if e % 6 == 0 && miller_rabin_prime(e/6)
    end

    triplets
  end

  def step4(triplets)

    success_triplets = []

    triplets.each do |triple|
      test4 = true

      (1..@m).each do |i|
        test4 = test4 && triple[:p] != triple[:r] && triple[:p].pow(i, triple[:r]) != 1
      end

      success_triplets << triple if test4
    end

    success_triplets
  end

  def step5(triplets, p)
    triple = triplets[-1]

    to_step6 = false

    while !to_step6
      x0 = rand(1..p)
      y0 = rand(1..p)

      b = (y0 ** 2 - x0 ** 3).pow(1, p)

      case triple[:k]
      when 1
        to_step6 = true if lezhandr2(b, p) == -1 && lezhandr3(b, p) == -1 
      when 2
        to_step6 = true if lezhandr2(b, p) == -1 && lezhandr3(b, p) == 1
      when 3
        to_step6 = true if lezhandr2(b, p) == 1 && lezhandr3(b, p) == -1
      when 6
        to_step6 = true if lezhandr2(b, p) == 1 && lezhandr3(b, p) == 1
      end
    end

    {xo: x0, yo: y0, p: p, k: triple[:k], r: triple[:r], b: b}
  end

  def step6(data)
    n = data[:k] * data[:r]
    @curve = Points.new(a: 0, b: data[:b], p: data[:p])
    inf = @curve.mult({x: data[:xo], y: data[:yo]}, n)
    # pp inf
    return inf[:status] != :zero
  end

  def step7(data)
    @curve = Points.new(a: 0, b: data[:b], p: data[:p], debug_mode: @points_debug_mode)
    q = @curve.mult({x: data[:xo], y: data[:yo]}, data[:k])
    # pp q
    return {p: data[:p], b: data[:b], q: q, r: data[:r]}
  end

  private
  
  def gen_big_number()
    bin_str = '1'
    
    (@l - 2).times do
        bin_str += rand(2).to_s
    end

    bin_str += '1'

    num = bin_str.to_i(2)

    if @debug_mode == :all
      puts "[debug] Generating rand number of #{@l} binary length"
      puts "\tbin: #{bin_str}"
      puts "\tbignum: #{num}"
      puts
    # elsif @debug_mode == :default
    #   puts "Generated rand number of #{@l} binary length: #{num}"
    end

    num
  end

  def miller_rabin_prime(n, g = 50)
    return false if n == 1

    puts "[debug] Miller-Rabin test for #{n} (#{g} rounds)" if @debug_mode == :all

    d = n - 1
    s = 0

    while d % 2 == 0
      d /= 2
      s += 1
    end

    g.times do
      a = 2 + rand(n - 4)
      x = a.pow(d, n)  # x = (a**d) % n
      
      next if x == 1 || x == n - 1
      
      for r in (1..s - 1)
        x = x.pow(2, n) # x = (x**2) % n
          if x == 1
            puts "\tNumber #{n} is not prime!\n" if @debug_mode == :all
            # puts "Miller-Rabin test for #{n}: is not prime!" @debug_mode == :default
            return false 
          end
        break if x == n - 1
      end

      if x != n - 1
        puts "\tNumber #{n} is not prime!\n" if @debug_mode == :all
        # puts "Miller-Rabin test for #{n}: is not prime!" @debug_mode == :default
        return false
      end
    end

    if @debug_mode == :all
      puts "\tNumber #{n} is prime!\n" 
    elsif @debug_mode == :default
      puts "Miller-Rabin test for #{n}: is probably prime!"
    end

    true # probably
  end

  def gen_big_prime

    rand_int = gen_big_number
    
    while !miller_rabin_prime(rand_int)
      rand_int = gen_big_number
    end

    rand_int

  end

  def gcd_ext(a, b, first = true)
    # puts "using extended gcd(#{a}, #{b})" if @debug_mode == :all && first

    if a == 0
      return b, 0, 1
    else
      res, x, y = gcd_ext(b%a, a, false)
      #debug
      # sleep 0.5 if @debug_mode == :all
      # puts "gcd(#{a}, #{b}); koeff: (#{x}, #{y})" if @debug_mode == :all
      return res, y - (b / a) * x, x
    end
  end

  def inverse(a, md)
    # puts %{using inverse of #{a} in #{md}} if @debug_mode == :all
    gcd, x, _ = gcd_ext(a, md)
    # puts %{gcd = #{gcd}, x = #{x}} if @debug_mode == :all
    if gcd != 1
      raise "\nNo inverse element exists\n"
    else
      return x % md
    end
  end

  def set_ki(ai = 0, q = 0, p = 0)

    # if @debug_mode == :all
    #   puts "[debug] set_ki"
    #   puts "\tai:#{ai}, q:#{q}, p:#{p}\n"
    # end
    k = 0

    while ai.pow((2 ** k) * q, p) != 1
      # puts k if  @debug_mode == :all
      # sleep 0.2 if @debug_mode == :all
      k += 1 
    end

    k
  end

  def gluchov_algo(p = 0, sq = -3)

    a = sq + p
    q = p - 1
    m = 0
    
    while q % 2 == 0
      m += 1 
      q = q / 2
    end

    b = rand(p)
    while lezhandr2(b, p) != -1
      b = rand(p)
    end

    a_arr = [a]
    k_arr = []

    while k_arr[-1] != 0
      ki = set_ki(a_arr[-1], q, p)
      a_arr << (a_arr[-1] * b.pow(2.pow(m - ki, p), p)).pow(1, p)
      k_arr << ki
    end

    r_arr = [a_arr[-1].pow((q + 1) / 2, p)]
    k_arr = k_arr.reverse()
    k_arr.delete(0)

    k_arr.each do |ki|
      r_arr << (r_arr[-1] * inverse(b ** (2 ** (m - ki - 1)) , p)).pow(1,p)
    end

    r_arr.last
  end

  def reactualize(p)
    res = []
    (0..Math.sqrt(p).to_i).each do |a|
      (0..Math.sqrt(p).to_i).each do |b|
        if a ** 2 + 3 * b ** 2 == p
          res << a
          res << b
        end
      end
    end
    pp res
  end

  def lezhandr2(a, p)
    return 0 if a % p == 0

    a.pow((p-1)/2, p) == 1 ? 1 : -1
  end

  def lezhandr3(a, p)
    return 0 if a % p == 0

    a.pow((p-1)/3, p) == 1 ? 1 : -1
  end

end
