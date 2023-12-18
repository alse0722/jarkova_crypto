require './steps.rb'

params = {
  debug_mode: true,
  loader_debug_mode: true,
  by_steps_mode:false
}

@steps = Steps.new(params)

step = 1

while step != 0
  puts "\nВыберите шаг:"
  puts "\t[1] - Инициализация"
  puts "\t[2] - Генерация кривой"
  puts "\t[3] - Генерация ключей"
  puts "\t[4] - Генерация сообщения и подписи"
  puts "\t[5] - Проверка подписи"
  puts "\t[0] - Выход"
  step = gets.strip.to_i

  case step
  when 1
    step_result = @steps.step0
    if step_result[:status] != :ok
      step = 0
      puts step_result[:msg] + ". Программа прекращает работу"
    end
  when 2
    step_result = @steps.step1
    if step_result[:status] != :ok
      step = 0
      puts step_result[:msg] + ". Программа прекращает работу"
    end
  when 3
    substep = 1

    while substep != 0
      puts "\nВыберите опцию:"
      puts "\t[1] - Генерация числа random_l"
      puts "\t[2] - Генерация точки point_p"
      puts "\t[3] - Генерация ключа open_key"
      puts "\t[4] - Генерация ключа secret_key"
      puts "\t[5] - Проверка сгенерированных параметров"
      puts "\t[0] - Выход"
      substep = gets.strip.to_i

      case substep
      when 1
        @steps.step2(:random_l)
      when 2
        @steps.step2(:point_p)
      when 3
        @steps.step2(:open_key)
      when 4
        @steps.step2(:secret_key)
      when 5
        step_result = @steps.step2
        if step_result[:status] != :ok
          step = 0
          substep = 0
          puts step_result[:msg] + ". Программа прекращает работу"
        end
      end
    end
  when 4
    substep = 1

    while substep != 0
      puts "\nВыберите опцию:"
      puts "\t[1] - Ввести сообщение m"
      puts "\t[2] - Генерация числа random_k"
      puts "\t[3] - Генерация точки point_r"
      puts "\t[4] - Генерация числа e"
      puts "\t[5] - Генерация числа s"
      puts "\t[6] - Генерация пакета formed_message"
      puts "\t[7] - Проверка сгенерированных параметров"
      puts "\t[0] - Выход"
      substep = gets.strip.to_i

      case substep
      when 1
        @steps.step3(:get_message)
      when 2
        @steps.step3(:random_k)
      when 3
        @steps.step3(:point_r)
      when 4
        @steps.step3(:e)
      when 5
        @steps.step3(:s)
      when 6
        @steps.step3(:formed_message)
      when 7
        step_result = @steps.step3
        if step_result[:status] != :ok
          step = 0
          substep = 0
          puts step_result[:msg] + ". Программа прекращает работу"
        end
      end
    end
  when 5
    substep = 1

    while substep != 0
      puts "\nВыберите опцию:"
      puts "\t[1] - Генерация проверочной точки point_r_new"
      puts "\t[2] - Генерация проверочного числа e_new"
      puts "\t[3] - Проверка сгенерированных параметров"
      puts "\t[0] - Выход"
      substep = gets.strip.to_i

      case substep
      when 1
        @steps.step4(:point_r_new)
      when 2
        @steps.step4(:e_new)
      when 3
        step_result = @steps.step4
        if step_result[:status] != :ok
          step = 0
          substep = 0
          puts step_result[:msg] + ". Программа прекращает работу"
        else
          if step_result[:result]
            puts  "\nПроверка подписи пройдена. Программа прекращает работу"
          else
            puts  "\nПроверка подписи НЕ пройдена. Программа прекращает работу"
          end
        end
      end
    end
  end
end

# step_result = @steps.step0
# if step_result[:status] == :ok
#   gets
#   step_result = @steps.step1

#   if step_result[:status] == :ok
#     gets
#     step_result = @steps.step2
    
#     if step_result[:status] == :ok
#       gets
#       step_result = @steps.step3
      
#       if step_result[:status] == :ok
#         gets
#         step_result = @steps.step4
        
#         if step_result[:status] == :ok

#           if step_result[:result]
#             puts  "\nПроверка подписи пройдена. Программа прекращает работу"
#           else
#             puts  "\nПроверка подписи НЕ пройдена. Программа прекращает работу"
#           end
          
#         else
#           puts step_result[:msg] + ". Программа прекращает работу"
#         end

#       else
#         puts step_result[:msg] + ". Программа прекращает работу"
#       end

#     else
#       puts step_result[:msg] + ". Программа прекращает работу"
#     end

#   else
#     puts step_result[:msg] + ". Программа прекращает работу"
#   end

# else
#   puts step_result[:msg] + ". Программа прекращает работу"
# end
