require 'json'
require 'prime'
require 'time'
require './points.rb'
require './loader.rb'
require './tests.rb'
require './square.rb'

class Steps

  def initialize(params = {})
    @debug_mode = params.dig(:debug_mode)
    @loader_debug_mode = params.dig(:loader_debug_mode)

    @data_file = 'data.txt'
    @logs_file = 'logs.txt'
    @status = nil

    @loader = Loader.new(@data_file, @logs_file, @loader_debug_mode)
  end

  def step0
    puts "\nШаг 0: Установка начальных параметров системы"

    # Устанавливаем все параметры системы в nil
    form_start_data
    form_main_objects
    @loader.make_log(:step0, "Шаг 0: Установка начальных параметров системы", :ok, "\n")
    @loader.make_log(:step0, "Начальные параметры обнулены", :ok)

    #забираем с клавиатуры начальные параметры a,b,p, , берем параметры из файла, меняем и записываем
    params = get_start_params
    @points = Points.new(params)
    @data = @loader.read_data(@data_file, "Параметры системы")

    #обновляем параметры системы
    @data = update_data(@data, params)

    show_current_status if @debug_mode
    
    #логировние и запись состояния системы после шага в файл
    @loader.make_log(:step0, "Начальные параметры системы заданы", :ok)
    @loader.write_data(@data, @data_file, "Параметры системы после шага 0")

    return @tests.test_step0
  end

  def step1
    puts "\nШаг 1: Генерация случайной точки P на эллиптической кривой"

    if !@loader.test_all_files_ok
      # puts "\nФайлы data.txt или logs.txt неисправны или отсутсвуют. Программа завершает работу"
      return {status: :error, msg: "\nФайлы data.txt или logs.txt неисправны или отсутсвуют"}
    end

    @loader.make_log(:step1, "Шаг 1: Генерация случайной точки P на эллиптической кривой", :ok, "\n")

    #берем параметры из файла
    @data = @loader.read_data(@data_file, "Параметры системы")
    ts0 = @tests.test_step0

    return ts0 if ts0[:status]!= :ok

    gen_random_point

    @data[:point_p] = @points.make_point(@data[:x], @data[:y], :ok)

    show_current_status if @debug_mode

    #логировние и запись состояния системы после шага в файл
    @loader.make_log(:step0, "Параметры x,y найдены, выбрана случайная точка P", :ok)
    @loader.write_data(@data, @data_file, "Параметры системы после шага 1")

    return @tests.test_step1
  end

  def step2
    puts "\nШаг 2: Вычисляем параметр s = [sqrt4(p)]"

    if !@loader.test_all_files_ok
      # puts "\nФайлы data.txt или logs.txt неисправны или отсутсвуют. Программа завершает работу"
      return {status: :error, msg: "\nФайлы data.txt или logs.txt неисправны или отсутсвуют"}
    end

    @loader.make_log(:step2, "Шаг 2: Вычисляем параметр s = [sqrt4(p)]", :ok, "\n")

    #берем параметры из файла
    @data = @loader.read_data(@data_file, "Параметры системы")
    ts1 = @tests.test_step1

    return ts1 if ts1[:status]!= :ok

    @data[:s] = (Math.sqrt(Math.sqrt(@data[:p]))).to_i + 1

    show_current_status if @debug_mode

    #логировние и запись состояния системы после шага в файл
    @loader.make_log(:step2, "Вычислен параметр s = [sqrt4(p)]", :ok)
    @loader.write_data(@data, @data_file, "Параметры системы после шага 2")

    return @tests.test_step2
  end

  def step3
    puts "\nШаг 3: Генерируем массив точек вида 0, +-P, +-2P, ... , +-sP"

    if !@loader.test_all_files_ok
      # puts "\nФайлы data.txt или logs.txt неисправны или отсутсвуют. Программа завершает работу"
      return {status: :error, msg: "\nФайлы data.txt или logs.txt неисправны или отсутсвуют"}
    end

    @loader.make_log(:step3, "Шаг 3: Генерируем массив точек вида 0, +-P, +-2P, ... , +-sP", :ok, "\n")

    #берем параметры из файла
    @data = @loader.read_data(@data_file, "Параметры системы")
    ts2 = @tests.test_step2

    return ts2 if ts2[:status]!= :ok

    @data[:points_p] = [@zero]

    (1..@data[:s]).each do |i|
      start_point = @data[:point_p].clone
      @data[:points_p] << @points.mult(start_point, i)
      start_point = @data[:point_p].clone
      @data[:points_p] << @points.mult(start_point, -i)
    end

    show_current_status if @debug_mode

    #логировние и запись состояния системы после шага в файл
    @loader.make_log(:step3, "Сгенерирован массив точек вида 0, +-P, +-2P, ... , +-sP", :ok)
    @loader.write_data(@data, @data_file, "Параметры системы после шага 3")

    return @tests.test_step3
  end

  def step4
    puts "\nШаг 4: Вычисляем точки Q = [2s+1]P и R = [p+1]P"

    if !@loader.test_all_files_ok
      # puts "\nФайлы data.txt или logs.txt неисправны или отсутсвуют. Программа завершает работу"
      return {status: :error, msg: "\nФайлы data.txt или logs.txt неисправны или отсутсвуют"}
    end

    @loader.make_log(:step4, "Шаг 4: Вычисляем точки Q = [2s+1]P и R = [p+1]P", :ok, "\n")

    #берем параметры из файла
    @data = @loader.read_data(@data_file, "Параметры системы")
    ts3 = @tests.test_step3

    return ts3 if ts3[:status]!= :ok

    @data[:point_q] = @points.mult(@data[:point_p], 2 * @data[:s] + 1)
    @data[:point_r] = @points.mult(@data[:point_p], @data[:p] + 1)

    show_current_status if @debug_mode

    #логировние и запись состояния системы после шага в файл
    @loader.make_log(:step4, "Вычислены точки Q = [2s+1]P и R = [p+1]P", :ok)
    @loader.write_data(@data, @data_file, "Параметры системы после шага 4")

    return @tests.test_step4
  end

  def step5
    puts "\nШаг 5: Вычисляем точки вида R +- [i]Q, для всех i = (0..s)"

    if !@loader.test_all_files_ok
      # puts "\nФайлы data.txt или logs.txt неисправны или отсутсвуют. Программа завершает работу"
      return {status: :error, msg: "\nФайлы data.txt или logs.txt неисправны или отсутсвуют"}
    end

    @loader.make_log(:step4, "Шаг 5: Вычисляем точки вида R +- [i]Q, для всех i = (0..s)", :ok, "\n")

    #берем параметры из файла
    @data = @loader.read_data(@data_file, "Параметры системы")
    ts4 = @tests.test_step4

    return ts4 if ts4[:status]!= :ok

    @data[:points_rq] = []
    (0..@data[:s]).each do |i|
      @data[:points_rq] << @points.sum(@data[:point_r], @points.mult(@data[:point_q], i))
      @data[:points_rq] << @points.sum(@data[:point_r], @points.inverse2(@points.mult(@data[:point_q], i), @data[:p]))
    end

    show_current_status if @debug_mode

    #логировние и запись состояния системы после шага в файл
    @loader.make_log(:step5, "Вычислены точки вида R +- [i]Q, для всех i = (0..s)", :ok)
    @loader.write_data(@data, @data_file, "Параметры системы после шага 5")

    return @tests.test_step5
  end

  def step6
    puts "\nШаг 6: Составляем пары (i,j) для всех j=(0..s), для точек вида R +- [i]Q совпадающими с точками вида +-iP"

    if !@loader.test_all_files_ok
      # puts "\nФайлы data.txt или logs.txt неисправны или отсутсвуют. Программа завершает работу"
      return {status: :error, msg: "\nФайлы data.txt или logs.txt неисправны или отсутсвуют"}
    end

    @loader.make_log(:step6, "Шаг 6: Составляем пары (i,j) для всех j=(0..s), для точек вида R +- [i]Q совпадающими с точками вида +-iP", :ok, "\n")

    #берем параметры из файла
    @data = @loader.read_data(@data_file, "Параметры системы")
    ts5 = @tests.test_step5

    return ts5 if ts5[:status]!= :ok

    counter = 0
    pairs = []

    @data[:points_rq].each_with_index do |point, i|
      pairs << {point: point, i: counter * (i.even? ? 1 : -1)}
      counter += 1 if !i.even?
    end

    @data[:koeffs_ij] = []

    @data[:points_p].each do |p_point|
      pairs.each do |rqi_pair|
        if p_point == rqi_pair[:point]
          (0..@data[:s]).each {|j| @data[:koeffs_ij] << {i:rqi_pair[:i], j: j}}
          (0..@data[:s]).each {|j| @data[:koeffs_ij] << {i:rqi_pair[:i], j: -j}}
        end
      end
    end

    @data[:koeffs_ij].uniq!

    show_current_status if @debug_mode

    #логировние и запись состояния системы после шага в файл
    @loader.make_log(:step6, "Шаг 6: Составлены пары (i,j) для всех j=(0..s), и i таких, что (R +- [i]Q) == (+-iP)", :ok)
    @loader.write_data(@data, @data_file, "Параметры системы после шага 6")

    return @tests.test_step5
  end

  def step7
    puts "\nШаг 7: Вычисляем из пар (i, j) параметры mi = p + 1 + (2 * s + 1) * i - j" \
      " и найдем порядок эллиптической кривой выполнив проверку ZERO == [mi]P."

    if !@loader.test_all_files_ok
      # puts "\nФайлы data.txt или logs.txt неисправны или отсутсвуют. Программа завершает работу"
      return {status: :error, msg: "\nФайлы data.txt или logs.txt неисправны или отсутсвуют"}
    end
    
    @loader.make_log(:step6, "Шаг 7: Вычисляем из пар (i, j) параметры mi = p + 1 + (2 * s + 1) * i - j" \
      " и найдем порядок эллиптической кривой выполнив проверку ZERO == [mi]P.", :ok, "\n")

    #берем параметры из файла
    @data = @loader.read_data(@data_file, "Параметры системы")
    ts6 = @tests.test_step6

    return ts6 if ts6[:status]!= :ok

    @data[:m_variants] = []

    @data[:koeffs_ij].each do |koeff|
      m_var = @data[:p] + 1 + (2 * @data[:s] + 1) * koeff[:i] - koeff[:j]
      @data[:m_variants] << m_var if check_candidate(@data[:point_p], m_var)
    end
 
    cleanup_candidates if @data[:m_variants].count > 1

    @data[:m] = @data[:m_variants].min

    show_current_status if @debug_mode

    #логировние и запись состояния системы после шага в файл
    @loader.make_log(:step7, "Шаг 7: Вычислены из пар (i, j) параметры mi = p + 1 + (2 * s + 1) * i - j" \
      " и найден порядок эллиптической кривой выполнив проверку ZERO == [mi]P.", :ok)
    @loader.write_data(@data, @data_file, "Параметры системы после шага 7")

    @tests.test_step7

    return {m: @data[:m], candidates: @data[:m_variants]}
  end

  private

  def get_start_params

    @p = 1

    puts "\nВведите простое число p:"
    @p = gets.to_i

    while !@p.prime?
      puts "\nЧисло p не простое. Повторите ввод:"
      @p = gets.to_i
    end

    puts "\nВведите коэффициенты уравнения эллиптической кривой (a b):"
    @a, @b = gets.strip.split.map(&:to_i)

    while check_curve_params
      puts "\nКривая с заданными параметрами a, b и p является вырожденной, повторите ввод (a b):"
      @a, @b = gets.strip.split.map(&:to_i)
    end

    if @debug_mode
      puts "\nВведены начальные параметры:"
      puts "\ta: #{@a}"
      puts "\tb: #{@b}"
      puts "\tp: #{@p}"
    end

    {
      p: @p,
      a: @a,
      b: @b
    }
  end

  def form_start_data
    @zero = {x: :none, y: :none, status: :zero}

    @data = {
      a:            nil,
      b:            nil,
      p:            nil,
      x:            nil,
      y:            nil,
      s:            nil,
      m:            nil,
      point_p:      nil,
      point_q:      nil,
      point_r:      nil,
      points_p:     nil,
      points_rq:    nil,
      koeffs_ij:    nil,
      m_variants:   nil
    }
  end

  def form_main_objects
    @zero = {x: :none, y: :none, status: :zero}

    @tests  = Tests.new(loader: @loader)

    @loader.recreate_file(@logs_file)
    @loader.recreate_file(@data_file)

    @loader.write_data(@data, @data_file, "Начальные (нулевые) параметры")
  end

  def show_current_status
    puts "\nТекущее состояние системы:"
    pp @data
  end

  def update_data(old_data, new_data)
    new_data.each_key do |key|
      old_data[key] = new_data[key]
    end

    old_data
  end

  def gen_random_point
    @data[:x] = rand(@data[:p])

    sqr = count_sqrt

    while jacobi(sqr, @data[:p]) != 1
      @data[:x] = (@data[:x] + 1) % @data[:p]
      sqr = count_sqrt
    end

    @data[:y] = Square.new.call(sqr, @data[:p])

    while @data[:y] == @data[:p] || @data[:x] == @data[:p] || jacobi(@data[:y], @data[:p]) != 1
      
      @data[:x] = (@data[:x] + 1) % @data[:p]

      sqr = count_sqrt

      while jacobi(sqr, @data[:p]) != 1
        @data[:x] = (@data[:x] + 1) % @data[:p]
        sqr = count_sqrt
      end

      @data[:y] = Square.new.call(sqr, @data[:p])
    end

  end

  def gen_next_point
    @data[:x] = (@data[:x] + 1) % @data[:p]
    @data[:y] = Square.new.call(count_sqrt, @data[:p])

    while @data[:y] == @data[:p] || @data[:x] == @data[:p] || jacobi(@data[:y], @data[:p]) != 1
      @data[:x] = (@data[:x] + 1) % @data[:p]
      @data[:y] = Square.new.call(count_sqrt, @data[:p])
    end
  end

  def check_candidate(point, m_var)
    @points.mult(point, m_var)[:status] == :zero && check_m_ranges(m_var)
  end

  def cleanup_candidates
    cnt = 1
    (@data[:m_variants].max).times do
      gen_random_point
      new_point = @points.make_point(@data[:x], @data[:y], :ok)

      old_candidates = @data[:m_variants]
      
      @data[:m_variants] = []

      if jacobi(new_point[:y], @data[:p]) == 0
        @data[:m_variants] = old_candidates
      else
        old_candidates.each {|m| @data[:m_variants] << m if check_candidate(new_point, m)}
      end

      cnt+=1
    end
  end

  def check_curve_params
    (4 * (@a ** 3) + 27 * (@b ** 2)) % @p == 0
  end

  def check_m_ranges(m)
    @data[:p] + 1 - 2 * Math.sqrt(@data[:p]) <= m && m <= @data[:p] + 1 + 2 * Math.sqrt(@data[:p])
  end

  def count_sqrt
    @data[:x] ** 3 + @data[:a] * @data[:x] + @data[:b]
  end

  def jacobi(a, n)
    if n < 3 || n % 2 == 0
      puts "Нет решения! p должно быть нечетным и больше 2"
      return nil
    end
  
    a = a % n
  
    t = 1
  
    while a != 0
      while a % 2 == 0
        a /= 2
        r = n % 8
        if r == 3 || r == 5
          t = -t
        end
      end
  
      a, n = n, a
      if a % 4 == 3 && n % 4 == 3
        t = -t
      end
  
      a %= n
    end
  
    if n == 1
      return t
    else
      return 0
    end
  end

end