require 'prime'

class Tests
  def initialize(params = {})
    @loader = params.dig(:loader)
    @debug_mode = params.dig(:debug_mode)
    @status = :ok
  end

  def test_step0
    @td = @loader.get_data

    test_result = (
      test_existance(:test_step0, [:a, :b, :p]) &&
      test_p_is_prime(:test_step0)
    )
  
    
    
    a_test = !@td[:a].nil?
    test_result = {status: :error, msg: 'Число a отсутсвует'} if !a_test
    @loader.make_log(:test_step0, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    b_test = !@td[:b].nil?
    test_result = {status: :error, msg: 'Число b отсутсвует'} if !b_test
    @loader.make_log(:test_step0, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    p_test = !@td[:p].nil? && @td[:p].prime?
    test_result = {status: :error, msg: 'Число p отсутсвует или не является простым'} if !p_test
    @loader.make_log(:test_step0, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    test_result = {status: :ok, msg: 'Проверка параметров шага 0 пройдена успешно'} if test_result
    @loader.make_log(:test_step0, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step1
    test_result = nil
    @td = @loader.get_data

    x_test = !@td[:point_p][:x].nil?
    test_result = {status: :error, msg: 'Координата x точки P отсутсвует'} if !x_test
    @loader.make_log(:test_step1, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    y_test = !@td[:point_p][:y].nil?
    test_result = {status: :error, msg: 'Координата y точки P отсутсвует'} if !y_test
    @loader.make_log(:test_step1, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    point_p_test = !@td[:point_p].nil? && @td[:point_p][:status] != :zero
    test_result = {status: :error, msg: 'Точка P выбрана неверно'} if !point_p_test
    @loader.make_log(:test_step1, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    point_p_in_curve_test = (@td[:point_p][:y] ** 2).pow(1, @td[:p]) == (@td[:point_p][:x] ** 3 + @td[:a] * @td[:point_p][:x] + @td[:b]).pow(1, @td[:p])
    test_result = {status: :error, msg: 'Точка P не принадлежит эллиптической кривой'} if !point_p_in_curve_test
    @loader.make_log(:test_step1, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    test_result = {status: :ok, msg: 'Проверка параметров шага 1 пройдена успешно'}
    @loader.make_log(:test_step1, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step2
    test_result = nil
    @td = @loader.get_data

    s_test = !@td[:s].nil? && @td[:s] == (Math.sqrt(Math.sqrt(@td[:p]))).to_i + 1
    test_result = {status: :error, msg: 'Параметр s отсутсвует или вычислен неверно'} if !s_test
    @loader.make_log(:test_step2, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    test_result = {status: :ok, msg: 'Проверка параметров шага 2 пройдена успешно'}
    @loader.make_log(:test_step2, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step3
    test_result = nil
    @td = @loader.get_data

    point_p_in_curve_test = (@td[:point_p][:y] ** 2).pow(1, @td[:p]) == (@td[:point_p][:x] ** 3 + @td[:a] * @td[:point_p][:x] + @td[:b]).pow(1, @td[:p])
    test_result = {status: :error, msg: 'Точка P не принадлежит эллиптической кривой'} if !point_p_in_curve_test
    @loader.make_log(:test_step3, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    points_p_in_curve_test = true
    zero_point_test = false
    @td[:points_p].each do |point|
      if point[:status] == :zero
        points_p_in_curve_test &= true
        zero_point_test = true
      else
        points_p_in_curve_test &= (point[:y] ** 2).pow(1, @td[:p]) == (point[:x] ** 3 + @td[:a] * point[:x] + @td[:b]).pow(1, @td[:p])
      end
    end
    test_result = {status: :error, msg: 'Некоторые из массива points_p не принадлежит эллиптической кривой'} if !points_p_in_curve_test
    @loader.make_log(:test_step3, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    points_p_count_test = @td[:points_p].count == 2 * @td[:s] + 1
    test_result = {status: :error, msg: 'Количество точек в массиве points_p мало'} if !points_p_count_test
    @loader.make_log(:test_step3, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    test_result = {status: :error, msg: 'Нет точки на бесконечности в массиве points_p'} if !zero_point_test
    @loader.make_log(:test_step3, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    test_result = {status: :ok, msg: 'Проверка параметров шага 3 пройдена успешно'}
    @loader.make_log(:test_step3, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step4
    test_result = nil
    @td = @loader.get_data

    s_test = !@td[:s].nil? && @td[:s] == (Math.sqrt(Math.sqrt(@td[:p]))).to_i + 1
    test_result = {status: :error, msg: 'Параметр s отсутсвует или вычислен неверно'} if !s_test
    @loader.make_log(:test_step4, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    point_p_in_curve_test = (@td[:point_p][:y] ** 2).pow(1, @td[:p]) == (@td[:point_p][:x] ** 3 + @td[:a] * @td[:point_p][:x] + @td[:b]).pow(1, @td[:p])
    test_result = {status: :error, msg: 'Точка P не принадлежит эллиптической кривой'} if !point_p_in_curve_test
    @loader.make_log(:test_step4, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    point_q_in_curve_test = (@td[:point_q][:y] ** 2).pow(1, @td[:p]) == (@td[:point_q][:x] ** 3 + @td[:a] * @td[:point_q][:x] + @td[:b]).pow(1, @td[:p])
    test_result = {status: :error, msg: 'Точка Q не принадлежит эллиптической кривой'} if !point_p_in_curve_test
    @loader.make_log(:test_step4, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?
    
    point_r_in_curve_test = (@td[:point_r][:y] ** 2).pow(1, @td[:p]) == (@td[:point_r][:x] ** 3 + @td[:a] * @td[:point_r][:x] + @td[:b]).pow(1, @td[:p])
    test_result = {status: :error, msg: 'Точка R не принадлежит эллиптической кривой'} if !point_r_in_curve_test
    @loader.make_log(:test_step4, test_result[:msg], test_result[:status]) if !test_result.nil?
    return test_result if !test_result.nil?

    test_result = {status: :ok, msg: 'Проверка параметров шага 4 пройдена успешно'}
    @loader.make_log(:test_step4, test_result[:msg], test_result[:status])

    return test_result
  end

  private

  def test_existance(step, params = [])
    all_good = true
    params.each {|key| all_good &= !@td[key.to_sym].nil?}

    if all_good
      @loader.make_log(step, "Необходимые для шага параметры #{params} присутвуют", :ok) if @debug_mode
    else
      @loader.make_log(step, "Необходимые для шага параметры #{params} присутвуют", :error) if @debug_mode
    end

    all_good
  end

  def test_p_is_prime(step)
    all_good = true

    all_good &= @td[:p].prime?

    if all_good
      @loader.make_log(step, "Число p - простое", :ok)
    else
      @loader.make_log(step, "Число p - не простое", :error)
    end

    all_good
  end

  def test_point_fullness(step, point, solo = false)
    all_good = true

    all_good &= !point[:x].null? && !point[:y].null? && !point[:status].null?

    if all_good
      @loader.make_log(step, "Точка #{point_name.to_s} задана верно", :ok) if @debug_mode && solo
    else
      @loader.make_log(step, "Точка #{point_name.to_s} задана неверно", :error) if @debug_mode
    end

    all_good
  end

  def test_point_in_curve(step, point)
    all_good = true



    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end

  def test_s_is_sqrt4
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
  
  def test_points_array_count
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
  
  def test_zero_point_in_array
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
  
  def test_
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
  
  def test_
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
  
  def test_
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
  
  def test_
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
  
  def test_
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
  
  def test_
    all_good = true

    if all_good
      @loader.make_log(step, "", :ok)
    else
      @loader.make_log(step, "", :error)
    end
  end
end