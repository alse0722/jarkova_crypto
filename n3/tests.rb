require 'prime'

class Tests
  def initialize(params = {})
    @debug_mode = params.dig(:debug_mode) || true
    
    @mess_loader = params.dig(:mess_loader)
    @logs_loader = params.dig(:logs_loader)
    @curve_loader = params.dig(:curve_loader)
    @open_key_loader = params.dig(:open_key_loader)
    @secret_key_loader = params.dig(:secret_key_loader)
    @formed_message_loader = params.dig(:formed_message_loader)
  end

  def test_step0

    all_good = (
      test_existance(@curve_loader, :test_step1, [:a, :b, :p, :point_q, :r], :start) &&
      test_existance(@open_key_loader, :test_step2, [:a, :b, :p, :r, :point_q, :point_p], :start) &&
      test_existance(@secret_key_loader, :test_step2, [:l], :start) &&
      test_existance(@formed_message_loader, :test_step3, [:m, :e, :s], :start)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 0 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 0 не пройдена'}
    end

    @logs_loader.make_log(:test_step0, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_mess0

    all_good = (
      test_existance(@mess_loader, :test_mess0, [:a, :b, :p, :point_q, :r], :start) &&
      test_existance(@mess_loader, :test_mess0, [:a, :b, :p, :r, :point_q, :point_p], :start) &&
      test_existance(@mess_loader, :test_mess0, [:l], :start) &&
      test_existance(@mess_loader, :test_mess0, [:m, :e, :s], :start)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 0 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 0 не пройдена'}
    end

    @logs_loader.make_log(:test_mess0, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step1
    @cd = @curve_loader.get_data

    all_good = (
      test_existance(@curve_loader, :test_step1, [:a, :b, :p, :point_q, :r]) &&
      test_value_is_prime(:test_step1, @cd[:p], :p) &&
      test_value_is_zero(:test_step1, @cd[:a], :a) &&
      test_value_in_range(:test_step1, @cd[:b], 0, @cd[:p], :b) &&
      test_point_fullness(:test_step1, @cd[:point_q], :point_q) &&
      test_point_in_curve(:test_step1, @cd[:point_q], @cd, :point_q) &&
      test_generator(:test_step1, @cd[:point_q], @cd[:r], :r)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 1 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 1 не пройдена'}
    end

    @logs_loader.make_log(:test_step1, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_mess1
    @ms = @mess_loader.get_data

    all_good = (
      test_existance(@mess_loader, :test_mess1, [:a, :b, :p, :point_q, :r]) &&
      test_value_is_prime(:test_mess1, @ms[:p], :p) &&
      test_value_is_zero(:test_mess1, @ms[:a], :a) &&
      test_value_in_range(:test_mess1, @ms[:b], 0, @ms[:p], :b) &&
      test_point_fullness(:test_mess1, @ms[:point_q], :point_q) &&
      test_point_in_curve(:test_mess1, @ms[:point_q], @ms, :point_q) &&
      test_generator(:test_mess1, @ms[:point_q], @ms[:r], :r)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 1 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 1 не пройдена'}
    end

    @logs_loader.make_log(:test_mess1, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step2
    @ok = @open_key_loader.get_data
    @sk = @secret_key_loader.get_data

    all_good = (
      test_existance(@open_key_loader, :test_step2, [:a, :b, :p, :r, :point_q, :point_p]) &&
      test_existance(@secret_key_loader, :test_step2, [:l]) &&
      test_value_is_prime(:test_step2, @ok[:p], :p) &&
      test_value_is_zero(:test_step2, @ok[:a], :a) &&
      test_value_in_range(:test_step2, @ok[:b], 0, @ok[:p], :b) &&
      test_value_in_range(:test_step2, @sk[:l], 0, @ok[:p], :b) &&
      test_point_fullness(:test_step2, @ok[:point_q], :point_q) &&
      test_point_in_curve(:test_step2, @ok[:point_q], @ok, :point_q) &&
      test_point_fullness(:test_step2, @ok[:point_p], :point_p) &&
      test_point_in_curve(:test_step2, @ok[:point_p], @ok, :point_p) &&
      test_generator(:test_step2, @ok[:point_q], @ok[:r], :r) &&
      test_key_generation(:test_step2, @ok[:point_p], @ok[:point_q], @sk[:l])
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 2 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 2 не пройдена'}
    end

    @logs_loader.make_log(:test_step2, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_mess2
    @ms = @mess_loader.get_data

    all_good = (
      test_existance(@mess_loader, :test_mess2, [:a, :b, :p, :r, :point_q, :point_p]) &&
      test_existance(@mess_loader, :test_mess2, [:l]) &&
      test_value_is_prime(:test_mess2, @ms[:p], :p) &&
      test_value_is_zero(:test_mess2, @ms[:a], :a) &&
      test_value_in_range(:test_mess2, @ms[:b], 0, @ms[:p], :b) &&
      test_value_in_range(:test_mess2, @ms[:l], 0, @ms[:p], :b) &&
      test_point_fullness(:test_mess2, @ms[:point_q], :point_q) &&
      test_point_in_curve(:test_mess2, @ms[:point_q], @ms, :point_q) &&
      test_point_fullness(:test_mess2, @ms[:point_p], :point_p) &&
      test_point_in_curve(:test_mess2, @ms[:point_p], @ms, :point_p) &&
      test_generator(:test_mess2, @ms[:point_q], @ms[:r], :r) &&
      test_key_generation(:test_mess2, @ms[:point_p], @ms[:point_q], @ms[:l])
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 2 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 2 не пройдена'}
    end

    @logs_loader.make_log(:test_mess2, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_step3
    @ok = @open_key_loader.get_data

    all_good = (
      test_existance(@open_key_loader, :test_step3, [:a, :b, :p, :r, :point_q, :point_p]) &&
      test_existance(@formed_message_loader, :test_step3, [:m, :e, :s]) &&
      test_value_is_prime(:test_step3, @ok[:p], :p) &&
      test_value_is_zero(:test_step3, @ok[:a], :a) &&
      test_value_in_range(:test_step3, @ok[:b], 0, @ok[:p], :b) &&
      test_point_fullness(:test_step3, @ok[:point_q], :point_q) &&
      test_point_in_curve(:test_step3, @ok[:point_q], @ok, :point_q) &&
      test_point_fullness(:test_step3, @ok[:point_p], :point_p) &&
      test_point_in_curve(:test_step3, @ok[:point_p], @ok, :point_p) &&
      test_generator(:test_step3, @ok[:point_q], @ok[:r], :r)
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 3 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 3 не пройдена'}
    end

    @logs_loader.make_log(:test_step3, test_result[:msg], test_result[:status])

    return test_result
  end

  def test_mess3
    @ms = @mess_loader.get_data

    all_good = (
      test_existance(@mess_loader, :test_mess3, [:a, :b, :p, :r, :point_q, :point_p]) &&
      test_existance(@mess_loader, :test_mess3, [:l]) &&
      test_value_is_prime(:test_mess3, @ms[:p], :p) &&
      test_value_is_zero(:test_mess3, @ms[:a], :a) &&
      test_value_in_range(:test_mess3, @ms[:b], 0, @ms[:p], :b) &&
      test_value_in_range(:test_mess3, @ms[:l], 0, @ms[:p], :b) &&
      test_point_fullness(:test_mess3, @ms[:point_q], :point_q) &&
      test_point_in_curve(:test_mess3, @ms[:point_q], @ms, :point_q) &&
      test_point_fullness(:test_mess3, @ms[:point_p], :point_p) &&
      test_point_in_curve(:test_mess3, @ms[:point_p], @ms, :point_p) &&
      test_generator(:test_mess3, @ms[:point_q], @ms[:r], :r) &&
      test_key_generation(:test_mess3, @ms[:point_p], @ms[:point_q], @ms[:l])
    )

    if all_good
      test_result = {status: :ok, msg: 'Проверка параметров шага 3 пройдена успешно'}
    else
      test_result = {status: :error, msg: 'Проверка параметров шага 3 не пройдена'}
    end

    @logs_loader.make_log(:test_mess3, test_result[:msg], test_result[:status])

    return test_result
  end

  private

  def test_existance(loader, step, params = [], mode = :steps)
    all_good = true

    data = loader.get_data

    case mode
    when :steps
      params.each {|key| all_good &= !data[key.to_sym].nil?}
    when :start
      params.each {|key| all_good &= data[key.to_sym].nil?}
    end

    if all_good
      @logs_loader.make_log(step, "Необходимые для шага параметры #{params} присутвуют в файле #{loader.show_params[:data_file]}", :ok) if @debug_mode
    else
      @logs_loader.make_log(step, "Некоторые необходимые для шага параметры #{params} отсутвуют в файле #{loader.show_params[:data_file]}", :error) if @debug_mode
    end

    all_good
  end

  def test_value_is_prime(step, value, name = nil)
    all_good = true

    all_good &= value.prime?

    if all_good
      @logs_loader.make_log(step, "Число #{name.nil? ? value : name.to_s} - простое", :ok)
    else
      @logs_loader.make_log(step, "Число #{name.nil? ? value : name.to_s} - не простое", :error)
    end

    all_good
  end

  def test_point_fullness(step, point, point_name = nil)
    all_good = true

    all_good &= !point[:x].nil? && !point[:y].nil? && !point[:status].nil?

    if all_good
      @logs_loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} задана верно", :ok) if @debug_mode && !point_name.nil?
    else
      @logs_loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} задана неверно", :error) if @debug_mode
    end

    all_good
  end

  def test_point_in_curve(step, point, curve, point_name = nil)
    all_good = true

    all_good &= point[:status] == :zero ? true : (point[:y] ** 2).pow(1, curve[:p]) == (point[:x] ** 3 + curve[:a] * point[:x] + curve[:b]).pow(1, curve[:p])

    if all_good
      @logs_loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} принадлежит эллиптической кривой", :ok) if @debug_mode && !point_name.nil?
    else
      @logs_loader.make_log(step, "Точка #{point_name.nil? ? point : point_name.to_s} не принадлежит эллиптической кривой", :error) if @debug_mode
    end

    all_good
  end

  def test_value_is_zero(step, value, name = nil)
    all_good = true

    all_good &= value.zero?

    if all_good
      @logs_loader.make_log(step, "Число #{name.nil? ? value : name.to_s} равно 0", :ok)
    else
      @logs_loader.make_log(step, "Число #{name.nil? ? value : name.to_s} не равно 0", :error)
    end

    all_good
  end

  def test_value_in_range(step, value, l, r, name = nil)
    all_good = true

    all_good &= (value > l && value < r)

    if all_good
      @logs_loader.make_log(step, "Число #{name.nil? ? value : name.to_s} находится в промежутке (#{l}, #{r})", :ok)
    else
      @logs_loader.make_log(step, "Число #{name.nil? ? value : name.to_s} не находится в промежутке (#{l}, #{r})", :error)
    end

    all_good
  end

  def test_generator(step, point, value, name = nil)
    all_good = true

    all_good &= Points.new({
      a: @cd[:a],
      b: @cd[:b],
      p: @cd[:p]
    }).mult(point, value)[:status] == :zero

    if all_good
      @logs_loader.make_log(step, "Генератор подобран правильно", :ok)
    else
      @logs_loader.make_log(step, "Генератор подобран неправильно", :error)
    end

    all_good
  end

  def test_key_generation(step, point_p, point_q, l)
    all_good = true

    all_good &= point_p == Points.new(
      {
        a: @cd[:a],
        b: @cd[:b],
        p: @cd[:p]
      }
    ).mult(point_q, l)

    if all_good
      @logs_loader.make_log(step, "Ключи для заданной эллиптической кривой вычислены верно", :ok)
    else
      @logs_loader.make_log(step, "Ключи для заданной эллиптической кривой вычислены неверно", :error)
    end

    all_good
  end

end