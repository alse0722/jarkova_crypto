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