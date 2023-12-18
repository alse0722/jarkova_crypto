require './elliptic_curve.rb'
require './loader.rb'
require './tests.rb'
require 'json'
require 'prime'
require 'time'
require 'openssl'

class Steps
  def initialize(params = {})
    @debug_mode = params.dig(:debug_mode) || false
    @loader_debug_mode = params.dig(:random_loader_debug_mode) || false

    custom_dir = './files/'
    @logs_file = custom_dir + 'logs.txt'
    @data_file = custom_dir + 'data.txt'
    
    @logs_loader = Loader.new(@logs_file, @logs_file, @loader_debug_mode)
    @data_loader = Loader.new(@data_file, @logs_file, @loader_debug_mode)
  end

  def step0
    puts "\nШаг 0: Обнуление параметров системы, пересоздание файлов"

    form_start_data
    form_main_objects
    init_tests

    @logs_loader.make_log(:step0, "Шаг 0: Обнуление параметров системы, пересоздание файлов", :ok, "\n")
    @logs_loader.make_log(:step0, "Начальные параметры обнулены", :ok)

    puts "\nНачальные параметры обнулены"

    return {status: :error, msg: 'Ошибка чтения файла'} if !check_loaders

    return @tests.test_step0
  end

  def step1
    puts "\nШаг 1: Вычисление генератора эллиптической кривой с j = 0"

    return {status: :error, msg: 'Ошибка чтения файла'} if !check_loaders

    @logs_loader.make_log(:step1, "Шаг 1: Вычисление генератора эллиптической кривой с j = 0", :ok, "\n")

    ts0 = @tests.test_step0
    return ts0 if ts0[:status]!= :ok

    curve_generator = get_curve_generator

    show_current_status(curve_generator, :curve_generator) if @debug_mode

    puts "\nВычисление генератора эллиптической кривой с j = 0 завершено"

    @logs_loader.make_log(:step1, "Найден генератор эллиптической кривой", :ok)
    data = @data_loader.get_data
    @data_loader.write_data(data.merge!(curve_generator), @data_file)

    @data = @data_loader.get_data
    @data.merge!(curve_generator)
    @data_loader.write_data(@data, @data_file)

    return @tests.test_step1
  end

  def step2(substep = :check)
    puts "\nШаг 2: Вычисление открытого и закрытого ключей"

    return {status: :error, msg: 'Ошибка чтения файла'} if !check_loaders

    @logs_loader.make_log(:step2, "Шаг 2: Вычисление открытого и закрытого ключей", :ok, "\n")

    ts1 = @tests.test_step1
    return ts1 if ts1[:status]!= :ok

    case substep
    when :random_l
      data = @data_loader.get_data

      data[:random_l] = rand(1..data[:r])
      puts "Сгенерировано случайное число random_l: #{data[:random_l]}"
      
      @data_loader.write_data(data, @data_file)
    when :point_p
      data = @data_loader.get_data

      data[:point_p] = Points.new(
        {
          a: data[:a],
          b: data[:b],
          p: data[:p]
        }
      ).mult(data[:point_q], data[:random_l])

      puts "Сгенерирована точка point_p: #{data[:point_p]}"
      
      @data_loader.write_data(data, @data_file)
    when :open_key
      data = @data_loader.get_data

      data[:open_key] = {
        a:        data[:a],
        b:        data[:b],
        p:        data[:p],
        r:        data[:r],
        point_p:  data[:point_p],
        point_q:  data[:point_q]
      }

      puts "Сгенерирован открытый ключ open_key: #{data[:open_key]}"

      @data_loader.write_data(data, @data_file)
    when :secret_key
      data = @data_loader.get_data

      data[:secret_key] = {
        random_l: data[:random_l]
      }

      puts "Сгенерирован закрытый ключ secret_key: #{data[:secret_key]}"

      @data_loader.write_data(data, @data_file)
    when :check
      data = @data_loader.get_data
      pp data
    
      show_current_status(data[:open_key], :open_key) if @debug_mode
      show_current_status(data[:secret_key], :secret_key) if @debug_mode

      puts "\nШаг 2: Вычисление открытого и закрытого ключей завершено"

      @logs_loader.make_log(:step2, "Вычислен секретный ключ", :ok)
      @logs_loader.make_log(:step2, "Вычислен открытый ключ", :ok)

      return @tests.test_step2
    end
  end

  def step3(substep = :check)
    puts "\nШаг 3: Формирование сообщения с подписью"

    return {status: :error, msg: 'Ошибка чтения файла'} if !check_loaders

    @logs_loader.make_log(:step3, "Шаг 3: Формирование сообщения с подписью", :ok, "\n")

    ts2 = @tests.test_step2
    return ts2 if ts2[:status]!= :ok

    case substep
    when :get_message
      data = @data_loader.get_data
      
      data[:m] = get_message

      puts "Сгенерировано сообщение m: #{data[:m]}"

      @data_loader.write_data(data, @data_file)
    when :random_k
      data = @data_loader.get_data

      data[:random_k] = rand(0..data[:open_key][:r])

      puts "Сгенерировано число random_k: #{data[:random_k]}"

      @data_loader.write_data(data, @data_file)
    when :point_r
      data = @data_loader.get_data

      data[:point_r] = Points.new(
        {
          a: data[:open_key][:a],
          b: data[:open_key][:b],
          p: data[:open_key][:p]
        }
      ).mult(data[:open_key][:point_q], data[:random_k])
      
      puts "Сгенерирована точка point_r: #{data[:point_r]}"

      @data_loader.write_data(data, @data_file)
    when :e
      data = @data_loader.get_data

      data[:e] = one_way_hash(data[:m].to_s + data[:point_r].to_s).to_i(16)

      while data[:e].zero?
        data[:random_k] = rand(0..data[:open_key][:r])

        data[:point_r] = Points.new(
          {
            a: data[:open_key][:a],
            b: data[:open_key][:b],
            p: data[:open_key][:p]
          }
        ).mult(data[:open_key][:point_q], data[:random_k])

        data[:e] = one_way_hash(data[:m] + data[:point_r].to_s).to_i(16)
      end

      puts "Сгенерировано e: #{data[:e]}"

      @data_loader.write_data(data, @data_file)
    when :s
      data = @data_loader.get_data

      data[:s] = (data[:secret_key][:random_l] * data[:e] + data[:random_k]) % data[:open_key][:r]

      puts "Сгенерировано s: #{data[:s]}"

      @data_loader.write_data(data, @data_file)
    when :formed_message
      data = @data_loader.get_data

      data[:formed_message] = {
        m: data[:m],
        e: data[:e],
        s: data[:s]
      }

      puts "Сгенерировано передаваемое сообщение: #{data[:formed_message]}"

      @data_loader.write_data(data, @data_file)
    when :check
      data = @data_loader.get_data

      show_current_status(data[:random_k], :random_k) if @debug_mode
      show_current_status(data[:point_r], :point_r) if @debug_mode
      show_current_status(data[:formed_message], :formed_message) if @debug_mode

      puts "\nШаг 3: Формирование сообщения с подписью завершено"

      @logs_loader.make_log(:step2, "Формирование сообщения с подписью завершено", :ok)
      @data_loader.write_data(data, @data_file)

      return @tests.test_step3
    end
  end

  def step4(substep = :check)
    puts "\nШаг 4: Проверка сообщения с подписью"

    return {status: :error, msg: 'Ошибка чтения файла'} if !check_loaders

    @logs_loader.make_log(:step4, "Шаг 4: Проверка сообщения с подписью", :ok, "\n")

    ts3 = @tests.test_step3
    return ts3 if ts3[:status]!= :ok

    case substep
    when :point_r_new
      data = @data_loader.get_data

      @points = Points.new(
        {
          a: data[:open_key][:a],
          b: data[:open_key][:b],
          p: data[:open_key][:p]
        }
      )

      data[:point_r_new] = @points.sum(
        @points.mult(
          data[:open_key][:point_q],
          data[:formed_message][:s]),
        @points.inverse2(
          @points.mult(
            data[:open_key][:point_p],
            data[:formed_message][:e]),
            data[:open_key][:p]
        )
      )
      
      puts "Сгенерирована проверочная точка point_r_new: #{data[:point_r_new]}"

      @data_loader.write_data(data, @data_file)
    when :e_new
      data = @data_loader.get_data
      
      data[:e_new] = one_way_hash(data[:formed_message][:m].to_s + data[:point_r_new].to_s).to_i(16)

      puts "Сгенерировано проверочное e_new: #{data[:e_new]}"

      @data_loader.write_data(data, @data_file)
    when :check
      data = @data_loader.get_data

      show_current_status(data[:open_key], :open_key) if @debug_mode
      show_current_status(data[:formed_message], :formed_message) if @debug_mode
      show_current_status(data[:point_r_new], :point_r_new) if @debug_mode
      show_current_status(data[:e_new], :e_new) if @debug_mode

      puts "\nШаг 4: Проверка сообщения с подписью завершена"

      return {result: data[:formed_message][:e] == data[:e_new], status: :ok}
    end
  end

  private

  def get_curve_generator
    puts "\n[Генератор эллиптической кривой] Введите параметр l (l > 2):"
    l = gets.strip.to_i

    while l < 3
      puts "[Генератор эллиптической кривой] Параметр l слишком мал. Повторите ввод (l > 2):"
      l = gets.strip.to_i
    end

    puts "\n[Генератор эллиптической кривой] Введите параметр m:"
    m = gets.strip.to_i

    params = {
      debug_mode: 'none',
      by_steps: false,
      methods_params: {
        l: l,
        m: m,
        debug_mode: 'none',
        points_debug_mode: 'none'
      }
    }

    curve = EllipticCurve.new(params)
    forming_data = {a: 0}.merge(curve.get_generator)
  end

  def get_message
    puts "\nВведите сообщение m:"
    msg = gets.strip.to_s
  end

  def show_current_status(object = nil, name = nil)
    puts "\nТекущее состояние объекта #{name}:"
    pp object
  end

  def init_tests
    @tests = Tests.new(
      { 
        data_loader: @data_loader,
        logs_loader: @logs_loader
      }
    )
  end

  def form_start_data
    @zero = {x: :none, y: :none, status: :zero}

    @data = {
      a: nil,
      b: nil,
      p: nil,
      point_p: nil,
      r: nil,
      point_q: nil,
      m: nil,
      random_l: nil,
      random_k: nil,
      e: nil,
      s: nil
    }
  end

  def form_main_objects
    @logs_loader.recreate_file(@logs_file)

    @data_loader.recreate_file(@data_file)

    @data_loader.write_data(@data, @data_file, "Начальные (нулевые) параметры")
  end

  def one_way_hash(data)
    sha256 = OpenSSL::Digest::SHA256.new
    hashed_data = sha256.digest(data)

    hashed_data.unpack('H*')[0]
  end

  def check_loaders
    not_ok_loaders = []

    not_ok_loaders << @data_file if !@data_loader.test_all_files_ok

    not_ok_loaders.each do |file|
      puts "\n[system] Файл #{file} поврежден или удален!"
    end

    return not_ok_loaders.empty?
  end

end