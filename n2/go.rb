require './steps.rb'

params = {
  debug_mode: true,
  loader_debug_mode: true
}

@steps = Steps.new(params)

test_result = @steps.step0
if test_result[:status] == :ok
  gets
  test_result = @steps.step1
  
  if test_result[:status] == :ok
    gets
    test_result = @steps.step2
    
    if test_result[:status] == :ok
      gets
      test_result = @steps.step3
      
      if test_result[:status] == :ok
        gets
        test_result = @steps.step4

        if test_result[:status] == :ok
          gets
          test_result = @steps.step5
          
          if test_result[:status] == :ok
            gets
            test_result = @steps.step6
            
            if test_result[:status] == :ok
              gets
              test_result = @steps.step7
              
              puts "\nПорядок эллиптической кривой равен #{test_result}"
              puts "\nПоиск порядка эллиптической кривой завершен. Программа прекращает работу"
            else
              puts test_result[:msg] + ". Программа прекращает работу"
            end
          else
            puts test_result[:msg] + ". Программа прекращает работу"
          end
        else
          puts test_result[:msg] + ". Программа прекращает работу"
        end
      else
        puts test_result[:msg] + ". Программа прекращает работу"
      end
    else
      puts test_result[:msg] + ". Программа прекращает работу"
    end
  else
    puts test_result[:msg] + ". Программа прекращает работу"
  end
else
  puts test_result[:msg] + ". Программа прекращает работу"
end
# gets
# s2 = @steps.step2 if s1[:status] == :ok
# gets
# s3 = @steps.step3 if s2[:status] == :ok
# gets
# s4 = @steps.step4 if s3[:status] == :ok
# gets
# s5 = @steps.step5 if s4[:status] == :ok
# gets
# s6 = @steps.step6 if s5[:status] == :ok
# gets
# s7 = @steps.step7 if s6[:status] == :ok