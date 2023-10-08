require './methods.rb'


@methods = Methods.new({debug_mode: "none", l:12, m: 10})

# @methods.gen_big_number
# @methods.gen_big_prime
# puts @methods.step1
# puts @methods.step3(13,11,7)
# puts @methods.step4(@methods.step3(13,11,7))
# puts @methods.lezhandr(69, 97)
# res = @methods.gluchov_algo(103)
# while (res ** 2).pow(1, 103) != 100
#   # pp res
#   # sleep 0.1
#   res = @methods.gluchov_algo(103)
# end

# puts "res:"
# puts res

# a = 3
# b = 5
# p = 97

# @ec = Points.new(a:a, b:b, p: p, debug_mode: 'hui')
# pp @ec

# a = {x: 17, y: 10, status: :common}
# b = {x: 95, y: 31, status: :common}

# # pp @ec.sum(a,b)

# pp @ec.mult({x: 11, y:37}, 10005)
# pp @ec.mult2({x: 11, y:37}, 10005)


step1_res = @methods.step1
# pp step1_res

step2_res = @methods.step2(step1_res)
# pp step2_res

step3_res = @methods.step3(step1_res, step2_res[:c], step2_res[:d])
# pp step3_res

step4_res = @methods.step4(step3_res)
# pp step4_res

step5_res = @methods.step5(step4_res, step1_res)
# pp step5_res

step6_res = @methods.step6(step5_res)
while !step6_res
  pp step6_res
  step6_res = @methods.step6(step5_res)
end