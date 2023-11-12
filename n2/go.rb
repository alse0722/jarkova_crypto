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
              
              if test_result[:candidates].count == 1
                puts "\nПорядок эллиптической кривой равен #{test_result[:m]}"
                puts "\nПоиск порядка эллиптической кривой завершен. Программа прекращает работу"
              elsif test_result[:candidates].count == 0
                puts "\nПорядок эллиптической кривой не вычислен. Обратитесь к логам"
                puts "\nПоиск порядка эллиптической кривой завершен. Программа прекращает работу"
              else
                puts "\nНайдено несколько кандитатов, в качестве порядка эллиптической кривой выбран минимальный: #{test_result[:m]}"
                puts "\nПолный список кандидатов: #{test_result[:candidates]}" 
                puts "\nПоиск порядка эллиптической кривой завершен. Программа прекращает работу"
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
else
  puts test_result[:msg] + ". Программа прекращает работу"
end
