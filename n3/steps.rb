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
    @by_steps_mode = params.dig(:by_steps_mode) || true
    @loader_debug_mode = params.dig(:loader_debug_mode) || false

    custom_dir = './files/'
    @curve_file = custom_dir + 'curve_params.txt'
    @open_key_file = custom_dir + 'open_key.txt'
    @secret_key_file = custom_dir + 'secret_key.txt'
    @formed_message_file = custom_dir + 'formed_message.txt'
    @logs_file = custom_dir + 'logs.txt'

    @status = nil

    @logs_loader = Loader.new(@logs_file, @logs_file, @loader_debug_mode)
    @curve_loader = Loader.new(@curve_file, @logs_file, @loader_debug_mode)
    @open_key_loader = Loader.new(@open_key_file, @logs_file, @loader_debug_mode)
    @secret_key_loader = Loader.new(@secret_key_file, @logs_file, @loader_debug_mode)
    @formed_message_loader = Loader.new(@formed_message_file, @logs_file, @loader_debug_mode)
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

    show_current_status(curve_generator, :curve) if @debug_mode

    puts "\nВычисление генератора эллиптической кривой с j = 0 завершено"

    @logs_loader.make_log(:step1, "Найден генератор эллиптической кривой", :ok)
    @curve_loader.write_data(curve_generator, @curve_file)

    

    return @tests.test_step1
  end

  def step2
    puts "\nШаг 2: Вычисление открытого и закрытого ключей"

    return {status: :error, msg: 'Ошибка чтения файла'} if !check_loaders

    @logs_loader.make_log(:step2, "Шаг 2: Вычисление открытого и закрытого ключей", :ok, "\n")

    ts1 = @tests.test_step1
    return ts1 if ts1[:status]!= :ok

    c_gen = @curve_loader.get_data

    random_l = rand(1..c_gen[:r])

    point_p = Points.new(
      {
        a: c_gen[:a],
        b: c_gen[:b],
        p: c_gen[:p]
      }
    ).mult(c_gen[:point_q], random_l)

    @open_key.merge!(
      {
        a:        c_gen[:a],
        b:        c_gen[:b],
        p:        c_gen[:p],
        r:        c_gen[:r],
        point_p:  point_p,
        point_q:  c_gen[:point_q]
      }
    )

    @secret_key.merge!(
      {
        l: random_l
      }
    )
    
    show_current_status(@open_key, :open_key) if @debug_mode
    show_current_status(@secret_key, :secret_key) if @debug_mode

    puts "\nШаг 2: Вычисление открытого и закрытого ключей завершено"

    @secret_key_loader.write_data(@secret_key, @secret_key_file)
    @logs_loader.make_log(:step2, "Вычислен секретный ключ", :ok)

    @open_key_loader.write_data(@open_key, @open_key_file)
    @logs_loader.make_log(:step2, "Вычислен открытый ключ", :ok)
    
    

    return @tests.test_step2
  end

  def step3
    puts "\nШаг 3: Формирование сообщения с подписью"

    return {status: :error, msg: 'Ошибка чтения файла'} if !check_loaders

    @logs_loader.make_log(:step3, "Шаг 3: Формирование сообщения с подписью", :ok, "\n")

    ts2 = @tests.test_step2
    return ts2 if ts2[:status]!= :ok

    text = get_message

    @open_key = @open_key_loader.get_data
    @secret_key = @secret_key_loader.get_data

    e = 0

    while e.zero?
      random_k = rand(0..@open_key[:r])

      point_r = Points.new(
        {
          a: @open_key[:a],
          b: @open_key[:b],
          p: @open_key[:p]
        }
      ).mult(@open_key[:point_q], random_k)

      puts "old_r: #{point_r}"
      e = one_way_hash(text + point_r.to_s).to_i(16)
    end

    s = (@secret_key[:l] * e + random_k) % @open_key[:r]

    formed_message = {
      m: text,
      e: e,
      s: s
    }

    show_current_status(formed_message, :formed_message) if @debug_mode

    puts "\nШаг 3: Формирование сообщения с подписью завершено"

    @formed_message_loader.write_data(formed_message, @formed_message_file)
    @logs_loader.make_log(:step2, "Формирование сообщения с подписью завершено", :ok)

    

    return @tests.test_step3
  end


  def step4
    puts "\nШаг 4: Проверка сообщения с подписью"

    return {status: :error, msg: 'Ошибка чтения файла'} if !check_loaders

    @logs_loader.make_log(:step3, "Шаг 4: Проверка сообщения с подписью", :ok, "\n")

    ts3 = @tests.test_step3
    return ts3 if ts3[:status]!= :ok

    @open_key = @open_key_loader.get_data
    @formed_message = @formed_message_loader.get_data

    @points = Points.new(
      {
        a: @open_key[:a],
        b: @open_key[:b],
        p: @open_key[:p]
      }
    )

    point_r_new = @points.sum(      #[s]Q-[e]P
      @points.mult(                 #[s]Q
        @open_key[:point_q],        #Q
        @formed_message[:s]),       #s
      @points.inverse2(             #-[e]p
        @points.mult(               #[e]P
          @open_key[:point_p],      #P
          @formed_message[:e]),     #e
        @open_key[:p]               #modulo p
      )
    )


    puts "new_r: #{point_r_new}"

    e_new = one_way_hash(@formed_message[:m].to_s + point_r_new.to_s).to_i(16)
    puts "\nШаг 4: Проверка сообщения с подписью завершена"

    

    return {result: @formed_message[:e] == e_new, status: :ok}
  end


  private

  def get_curve_generator
    puts "\n[Elliptic curve generator] Enter l > 2"
    @l = gets.strip.to_i

    while @l < 3
      puts "[Elliptic curve generator] l is too low!\n\n[Input] Enter l > 2"
      @l = gets.strip.to_i
    end

    puts "\n[Elliptic curve generator] Enter m"
    @m = gets.strip.to_i

    params = {
      # bin_length: 12,
      # m_parameter: 13,
      debug_mode: 'none',
      by_steps: false,
      methods_params: {
        l: @l,
        m: @m,
        debug_mode: 'none',
        points_debug_mode: 'none'
      }
    }

    curve = EllipticCurve.new(params)
    # pp gen
    forming_data = {a: 0}.merge(curve.get_generator)
  end

  def get_message
    puts "\n[Shnorr] Enter any message"
    @msg = gets.strip.to_s
  end

  def show_current_status(object = nil, name = nil)
    puts "\nCurrent #{name.to_s} status:"
    pp object
  end

  def init_tests
    @tests = Tests.new(
      { 
        logs_loader: @logs_loader,
        curve_loader: @curve_loader,
        open_key_loader: @open_key_loader,
        secret_key_loader: @secret_key_loader,
        formed_message_loader: @formed_message_loader
      }
    )
  end

  def form_start_data
    @zero = {x: :none, y: :none, status: :zero}

    @curve = {
      a:        nil,
      b:        nil,
      p:        nil,
      r:        nil,
      q_point:  nil
    }

    @open_key = {
      a:        nil,
      b:        nil,
      p:        nil,
      r:        nil,
      q_point:  nil,
      p_point:  nil
    }

    @secret_key = {
      l:        nil
    }

    @msg =      nil

    @formed_message = {
      m:        nil,
      e:        nil,
      s:        nil
    }
  end

  def form_main_objects
    @curve_loader.recreate_file(@logs_file)

    @curve_loader.recreate_file(@curve_file)
    @open_key_loader.recreate_file(@open_key_file)
    @secret_key_loader.recreate_file(@secret_key_file)
    @formed_message_loader.recreate_file(@formed_message_file)

    @curve_loader.write_data(@curve, @curve_file, "Начальные (нулевые) параметры")
    @open_key_loader.write_data(@open_key, @open_key_file, "Начальные (нулевые) параметры")
    @secret_key_loader.write_data(@secret_key, @secret_key_file, "Начальные (нулевые) параметры")
    @formed_message_loader.write_data(@formed_message, @formed_message_file, "Начальные (нулевые) параметры")
  end

  def one_way_hash(data)
    sha256 = OpenSSL::Digest::SHA256.new
    hashed_data = sha256.digest(data)

    hashed_data.unpack('H*')[0]
  end

  def check_loaders
    not_ok_loaders = []

    # not_ok_loaders << @logs_loader.test_all_files_ok ? nil : @logs_file
    not_ok_loaders << @curve_file if !@curve_loader.test_all_files_ok
    not_ok_loaders << @open_key_file if !@open_key_loader.test_all_files_ok
    not_ok_loaders << @secret_key_file if !@secret_key_loader.test_all_files_ok
    not_ok_loaders << @formed_message_file if !@formed_message_loader.test_all_files_ok

    not_ok_loaders.each do |file|
      puts "\n[system] Файл #{file} поврежден или удален!"
    end

    return not_ok_loaders.empty?
  end

end