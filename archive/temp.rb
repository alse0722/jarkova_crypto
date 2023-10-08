a = sq + p
    q = p - 1
    m = 0
    

    while q % 2 == 0
      m += 1 
      q = q / 2
    end

    b = rand(p)
    while lezhandr(b, p) != -1
      b = rand(p)
    end

    a_array = [a]
    k_array = []

    if @debug_mode == :all
      puts "[debug] gluchov_algo"
      puts "\tp:#{p}, a:#{a}, q:#{q}, m:#{m}, b:#{b}"
      gets
    end

    loop do
      pp "a_array: #{a_array}"
      ki = set_ki(a_array[-1], q, p)
      a_next = a_array.last.pow(b.pow(2.pow(m - ki, p), p), p)
      puts "a_next: #{a_next}"
      break if ki == 0
      a_array << a_next
      k_array << ki
    end

    r_array = [a_array.last.pow((q+1)/2, p)]

    if @debug_mode == :all
      puts "\tarrays after loop:"
      pp "\ta_array: #{a_array}"
      pp "\tk_array: #{k_array}"
      pp "\tr_array: #{r_array}"
    end


    k_array.reverse()[1..-1].each do |ki|
      ri = (r_array.last * (gcd_ext(b ** (2 ** (m - ki - 1)) ,p)[1])).pow(1, p)
      r_array << ri
    end

    if @debug_mode == :all
      puts "\tr_array after k_array.reverse().each do:"
      pp "\tr_array: #{r_array}" 
    end

    r_array.last