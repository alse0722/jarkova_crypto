class Loader
  def initialize(data_file, logs_file, debug_mode = false)
    @data_file = data_file
    @logs_file = logs_file
    @debug_mode = debug_mode
  end

  def get_data
    @data = read_data(@data_file)
  end

  def write_data(hash, file_name, msg = '')
    data = hash.to_json
    File.write(file_name, data)
    
    if msg == ''
      str = "Данные записаны в файл #{file_name}"
    else
      str = msg + " записаны в файл #{file_name}"
    end
  end

  def add_data(str, file_name)
    File.open(file_name, 'a') do |file|
      file.puts str
    end
  end

  def read_data(file_name, msg = '')
    data = File.read(file_name)
    hash = JSON.parse(data, symbolize_names: true)
    hash = hash_to_atom_keys(hash)
    hash = symbolize_strings(hash)

    if msg == ''
      str = "Данные прочитаны из файла #{file_name}"
    else
      str = msg + " прочитаны из файла #{file_name}"
    end

    return hash
  end

  def recreate_file(file_name)
    if File.exist?(file_name)
      File.delete(file_name)
      puts "\n[system] Файл #{file_name} удален!"
    end
  
    File.new(file_name, 'w')
    puts "\n[system] Создан новый файл #{file_name}!"

    make_log(:loader, "Файл #{file_name} пересоздан", :ok)
  end

  def make_log(src, msg, status, add = '')
    src = "[#{src.to_s.center(10)}]"
    curr_time = "[#{time}]"
    status = "[#{status.to_s}]"
    msg = " " + msg
    log = [add, curr_time, status, src, msg].join
    add_data(log, @logs_file)
  end

  private

  def time
    Time.now.strftime('%Y-%m-%d %H:%M:%S').to_s
  end

  def hash_to_atom_keys(hash)
    hash.map { |k, v| [k.to_s.to_sym, v.is_a?(Hash) ? hash_to_atom_keys(v) : v] }.to_h
  end

  def symbolize_strings(obj)
    if obj.is_a?(Hash)
      obj.transform_values { |value| symbolize_strings(value) }
    elsif obj.is_a?(Array)
      obj.map { |item| symbolize_strings(item) }
    elsif obj.is_a?(String)
      obj.to_sym
    else
      obj
    end
  end

end