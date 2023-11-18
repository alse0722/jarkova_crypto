require './curve_methods.rb'


class EllipticCurve
  def initialize(params = {})
    @methods = Methods.new(params.dig(:methods_params))
    # @points = Points.new(params.dig(:points_params))

    @debug_mode = params.dig(:debug_mode).to_sym
    @by_steps = params.dig(:by_steps)
    @filename = params.dig(:filename).to_s
    # @bin_length = params.dig(:bin_length)
    # @m_parameter = params.dig(:m_parameter)
  end

  def get_generator

    pr_contest = true

    while pr_contest

      pnr_triplet_empty = true

      while pnr_triplet_empty
        s1 = @methods.step1
        puts "\n[S1] Generated prime p, p = 1 (mod 6) = #{s1}" if @debug_mode == :all
        gets if @by_steps

        s2 = @methods.step2(s1)
        if s2.empty?
          pnr_triplet_empty = true

          if @debug_mode == :all
            puts "\n[S2] Tried to expand p = c^2 + 3d^2 in Z_(sqrt (-3))"
            puts "\tFailed" if @debug_mode == :all
          end

          gets if @by_steps
        else
          if @debug_mode == :all
            puts "\n[S2] Tried to expand p = c^2 + 3d^2 in Z_(sqrt (-3))"
            puts "\tResult = #{s2}" if @debug_mode == :all
          end
          gets if @by_steps

          s3 = @methods.step3(s1, s2[:c], s2[:d])
          pnr_triplet_empty = s3.empty?

          if @debug_mode == :all
            puts "\n[S3] Testing pnr conditions with #{[s1, s2]} triplets"
            puts "\tGood triplets: #{s3} #{pnr_triplet_empty ? '--> Failed' : '--> Successed'}"
          end

          gets if @by_steps
        end
      end

      s4 = @methods.step4(s3)
      pr_contest = s4.empty?

      if @debug_mode == :all
        puts "\n[S4] Testing pr contest with #{s4} triplets"
        puts "\tGood triplets: #{s4} #{pr_contest ? '--> Failed' : '--> Successed'}"
      end
      gets if @by_steps
    end

    koefficient_test = true

    while koefficient_test
      s5 = @methods.step5(s4, s1)

      if @debug_mode == :all
        puts "\n[S5] Generated random T = (xo, yo), calculated B <-- yo^2 - xo^3 (mod p)"
        puts "\tSuccessfully finished Lezhandr's tests. Params below:"
        puts "\tT = (xo:#{s5[:xo]}, yo:#{s5[:yo]})"
        puts "\tB = #{s5[:b]}"
        puts "\tp = #{s5[:p]}"
        puts "\tr = #{s5[:r]}"
        puts "\tk = #{s5[:k]}"
      end
      gets if @by_steps

      s6 = @methods.step6(s5)

      if @debug_mode == :all
        puts "\n[S6] Testing N * (xo, yo) == O, where N = k * r, O is zero point"
        puts "\t#{s5[:k] * s5[:r]} * (#{s5[:xo]}, #{s5[:yo]}) =?= O"
        puts "\tKoefficient test result:  #{!s6 ? 'Success' : 'Failure'}"
      end
      
      koefficient_test = s6
      gets if @by_steps
    end

    s7 = @methods.step7(s5)
    if @debug_mode == :all
      puts "\n[S7] Generating Q = (N / r) * (xo, yo)"
      puts "\t#{s5[:k]} * (#{s5[:xo]}, #{s5[:yo]}) = #{s7[:q]}"
    end
    gets if @by_steps

    puts "\n[Elliptic curve generator] Formed generator (p, B, Q, r) of elliptic curve"
    puts "\tp = #{s7[:p]}"
    puts "\tB = #{s7[:b]}"
    puts "\tQ = #{s7[:q]}"
    puts "\tr = #{s7[:r]}"
    
    s7[:q][:status] = (s7[:q][:x].nil? || s7[:q][:y].nil?) ? :zero : :ok

    {
      b: s7[:b],
      p: s7[:p],
      r: s7[:r],
      point_q: s7[:q]
    }
  end
  
end

def start
  puts "\n[Elliptic curve generator] Enter l > 2"
  @l = gets.strip.to_i

  while @l < 3
    puts "[Elliptic curve generator] l is too low!\n\n[Input] Enter l > 2"
    @l = gets.strip.to_i
  end

  puts "\n[Elliptic curve generator] Enter m"
  @m = gets.strip.to_i

  params = {
    # bin_length: 12,
    # m_parameter: 13,
    debug_mode: 'none',
    by_steps: false,
    methods_params: {
      l: @l,
      m: @m,
      debug_mode: 'none',
      points_debug_mode: 'none'
    }
  }

  curve = EllipticCurve.new(params)
  # pp gen
  forming_data = {a: 0}.merge(curve.get_generator)
end

# generator = Generator.new({debug_mode: 'all', data: forming_data, filename: 'coordinates.txt'})
# # pp generator
# points = generator.start
# generator.to_file(points)
# # generator.show
