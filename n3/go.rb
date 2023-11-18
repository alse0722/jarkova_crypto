require './steps.rb'

params = {
  debug_mode: true,
  loader_debug_mode: true,
  by_steps_mode:false
}

@steps = Steps.new(params)

step_result = @steps.step0
if step_result[:status] == :ok
  gets
  step_result = @steps.step1

  if step_result[:status] == :ok
    gets
    step_result = @steps.step2
    
    if step_result[:status] == :ok
      gets
      step_result = @steps.step3
      
      if step_result[:status] == :ok
        gets
        step_result = @steps.step4
        
        if step_result[:status] == :ok

          if step_result[:result]
            puts  "\nПроверка подписи пройдена. Программа прекращает работу"
          else
            puts  "\nПроверка подписи НЕ пройдена. Программа прекращает работу"
          end
          
        else
          puts step_result[:msg] + ". Программа прекращает работу"
        end

      else
        puts step_result[:msg] + ". Программа прекращает работу"
      end

    else
      puts step_result[:msg] + ". Программа прекращает работу"
    end

  else
    puts step_result[:msg] + ". Программа прекращает работу"
  end

else
  puts step_result[:msg] + ". Программа прекращает работу"
end
