require './steps.rb'

params = {
  debug_mode: true,
  loader_debug_mode: true
}

@steps = Steps.new(params)

s0 = @steps.step0
s1 = @steps.step1 if s0[:status] == :ok
s2 = @steps.step2 if s1[:status] == :ok
s3 = @steps.step3 if s2[:status] == :ok
s4 = @steps.step4 if s3[:status] == :ok
s5 = @steps.step5 if s4[:status] == :ok
s6 = @steps.step6 if s5[:status] == :ok
s7 = @steps.step7 if s6[:status] == :ok