require 'prime'

class Tests
  def initialize(params = {})
    @loader = params.dig(:loader)
    @debug_mode = params.dig(:debug_mode) || true
    @status = :ok
  end

  def test_step0
    @td = @loader.get_data

    all_good = (
      test_existance(:test_step0, [:a, :b, :p]) &&
      test_p_is_prime(:test_step0)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 0 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 0 не пройдена'}
    end

    @loader.make_log(:test_step0, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step1
    @td = @loader.get_data

    all_good = (
      test_existance(:test_step1, [:a, :b, :p]) &&
      test_p_is_prime(:test_step1)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 1 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 1 не пройдена'}
    end
    
    @loader.make_log(:test_step1, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step2
    @td = @loader.get_data

    all_good = (test_existance(:test_step2, [:a, :b, :p, :s, :point_p]) &&
      test_p_is_prime(:test_step2) &&
      test_s_is_sqrt4(:test_step2) &&
      test_point_fullness(:test_step2, @td[:point_p], :p) &&
      test_point_in_curve(:test_step2, @td[:point_p], :p)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 2 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 2 не пройдена'}
    end
    
    @loader.make_log(:test_step2, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step3
    @td = @loader.get_data

    all_good = (
      test_existance(:test_step3, [:p, :s, :point_p]) &&
      test_p_is_prime(:test_step3) &&
      test_s_is_sqrt4(:test_step3) &&
      test_point_fullness(:test_step3, @td[:point_p], :p) &&
      test_point_in_curve(:test_step3, @td[:point_p], :p)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 3 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 3 не пройдена'}
    end
    
    @loader.make_log(:test_step3, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step4
    @td = @loader.get_data

    all_good = (test_existance(:test_step4, [:a, :b, :s, :p, :point_p, :point_r, :point_q]) &&
      test_s_is_sqrt4(:test_step4) &&
      test_p_is_prime(:test_step4) &&
      test_point_fullness(:test_step4, @td[:point_p], :p) &&
      test_point_in_curve(:test_step4, @td[:point_p], :p) &&
      test_point_fullness(:test_step4, @td[:point_r], :r) &&
      test_point_in_curve(:test_step4, @td[:point_r], :r) &&
      test_point_value(:test_step4, @td[:point_r], :r) &&
      test_point_fullness(:test_step4, @td[:point_q], :q) &&
      test_point_in_curve(:test_step4, @td[:point_q], :q) &&
      test_point_value(:test_step4, @td[:point_q], :q)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 4 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 4 не пройдена'}
    end
    
    @loader.make_log(:test_step4, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step5
    @td = @loader.get_data

    all_good = (test_existance(:test_step5, [:s, :points_p, :points_rq]) &&
      test_s_is_sqrt4(:test_step5) &&
      test_points_array_fullness(:test_step5, :points_p) &&
      test_points_array_in_curve(:test_step5, :points_p) &&
      test_points_array_count(:test_step5, :points_p) &&
      test_zero_point_in_array(:test_step5, :points_p) &&
      test_points_array_fullness(:test_step5, :points_rq) &&
      test_points_array_in_curve(:test_step5, :points_rq) &&
      test_points_array_count(:test_step5, :points_rq)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 5 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 5 не пройдена'}
    end
    
    @loader.make_log(:test_step5, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step6
    @td = @loader.get_data

    all_good = (test_existance(:test_step6, [:p, :s, :koeffs_ij, :point_p]) &&
      test_p_is_prime(:test_step6) &&
      test_s_is_sqrt4(:test_step6) &&
      test_koeffs_fullness(:test_step6, @td[:koeffs_ij], :ij) &&
      test_koeffs_values(:test_step6, @td[:koeffs_ij], :ij) &&
      test_point_fullness(:test_step6, @td[:point_p], :p) &&
      test_point_in_curve(:test_step6, @td[:point_p], :p)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 6 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 6 не пройдена'}
    end
    
    @loader.make_log(:test_step6, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step7
    @td = @loader.get_data

    all_good = (test_existance(:test_step7, [:m_variants, :point_p]) &&
      test_point_fullness(:test_step7, @td[:point_p], :p) &&
      test_point_in_curve(:test_step7, @td[:point_p], :p) &&
      test_koeffs_fullness(:test_step7, @td[:m_variants], :mi) &&
      test_koeffs_values(:test_step7, @td[:m_variants], :mi)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 7 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 7 не пройдена'}
    end
    
    @loader.make_log(:test_step7, test_result[:msg], test_result[:status])

    return test_result
  end

  private

  def test_existance(step, params = [])
    all_good = true
    params.each {|key| all_good &= !@td[key.to_sym].nil?}

    if all_good
      @loader.make_log(step, "Необходимые для шага параметры #{params} присутвуют", :ok) if @debug_mode
    else
      @loader.make_log(step, "Некоторые необходимые для шага параметры #{params} отсутвуют", :error) if @debug_mode
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

  def test_point_fullness(step, point, point_name = nil)
    all_good = true

    all_good &= !point[:x].nil? && !point[:y].nil? && !point[:status].nil?
    if all_good
      @loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} задана верно", :ok) if @debug_mode && !point_name.nil?
    else
      @loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} задана неверно", :error) if @debug_mode
    end

    all_good
  end

  def test_point_in_curve(step, point, point_name = nil)
    all_good = true

    all_good &= point[:status] == :zero ? true : (point[:y] ** 2).pow(1, @td[:p]) == (point[:x] ** 3 + @td[:a] * point[:x] + @td[:b]).pow(1, @td[:p])

    if all_good
      @loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} принадлежит эллиптической кривой", :ok) if @debug_mode && !point_name.nil?
    else
      @loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} не принадлежит эллиптической кривой", :error) if @debug_mode
    end

    all_good
  end

  def test_s_is_sqrt4(step)
    all_good = true

    all_good &= @td[:s] == (Math.sqrt(Math.sqrt(@td[:p]))).to_i + 1

    if all_good
      @loader.make_log(step, "Параметр s вычислен верно", :ok)
    else
      @loader.make_log(step, "Параметр s вычислен неверно", :error)
    end

    all_good
  end
  
  def test_points_array_count(step, array_name)
    all_good = true

    all_good &= case array_name
      when :points_p
        @td[:points_p].count == 2 * @td[:s] + 1
      when :points_rq
        @td[:points_rq].count == 2 * (@td[:s] + 1)
      else
        false
      end

    if all_good
      @loader.make_log(step, "Количество точек в массиве #{array_name} верное", :ok)
    else
      @loader.make_log(step, "Количество точек в массиве #{array_name} неверное", :error)
    end

    all_good
  end
  
  def test_zero_point_in_array(step, array_name)
    all_good = false

    @td[array_name].each {|point| all_good |= point[:status] == :zero}

    if all_good
      @loader.make_log(step, "В массиве #{array_name} имеется точка на бесконечности", :ok)
    else
      @loader.make_log(step, "В массиве #{array_name} не найдена точка на бесконечности", :error)
    end

    all_good
  end
  
  def test_points_array_in_curve(step, array_name)
    all_good = true

    @td[:points_p].each do |point|
      if point[:status] == :zero
        all_good &= true
      else
        all_good &= test_point_in_curve(step, point)
      end
    end

    if all_good
      @loader.make_log(step, "Все точки массива #{array_name} принадлежат кривой", :ok)
    else
      @loader.make_log(step, "Некоторые точки массива #{array_name} не принадлежат кривой", :error)
    end

    all_good
  end
  
  def test_points_array_fullness(step, array_name)
    all_good = true

    @td[:points_p].each do |point|
      all_good &= test_point_fullness(step, point)
    end

    if all_good
      @loader.make_log(step, "Все точки массива #{array_name} заданы верно", :ok)
    else
      @loader.make_log(step, "Некоторые точки массива #{array_name} заданы неверно", :error)
    end

    all_good
  end

  def test_point_value(step, point, point_name = nil)
    @points = Points.new(a: @td[:a], b: @td[:b], p: @td[:p])

    all_good = true

    all_good &= case point_name
    when :r
      point == @points.mult(@td[:point_p], @td[:p] + 1)
    when :q
      point == @points.mult(@td[:point_p], 2 * @td[:s] + 1)
    else
      false
    end

    if all_good
      @loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} найдена верно", :ok) if @debug_mode && !point_name.nil?
    else
      @loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} найдена неверно", :error)
    end

    all_good
  end
  
  def test_koeffs_fullness(step, koeffs, array_name)
    all_good = true

    case array_name
    when :ij
      koeffs.each do |koeff|
        all_good &= !koeff[:i].nil? && !koeff[:j].nil?
      end
    when :mi
      koeffs.each do |koeff|
        all_good &= !koeff.nil?
      end
    else
      all_good &=false
    end

    if all_good
      @loader.make_log(step, "Все коэффициенты в массиве #{array_name} заполнены", :ok)
    else
      @loader.make_log(step, "Некоторые коэффициенты в массиве #{array_name} не заполнены", :error)
    end

    all_good
  end
  
  def test_koeffs_values(step, koeffs, array_name)
    all_good = true

    case array_name
    when :ij
      koeffs.each do |koeff|
        all_good &= koeff[:i] <= @td[:s] && koeff[:j] <= @td[:s]
      end
    when :mi
      koeffs.each do |koeff|
        all_good &= (@td[:p] + 1 - 2 * Math.sqrt(@td[:p]) <= koeff &&
          koeff <= @td[:p] + 1 + 2 * Math.sqrt(@td[:p])
        )
      end
    else
      all_good &= false
    end

    if all_good
      @loader.make_log(step, "Все элементы массива #{array_name} находятся в пределах своих возможных значений", :ok)
    else
      @loader.make_log(step, "Некоторые элементы массива #{array_name} выходят за пределы своих возможных значений", :error)
    end

    all_good
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