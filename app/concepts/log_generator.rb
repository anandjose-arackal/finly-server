class LogGenerator
  attr_accessor :filename
  attr_reader :data

  LOGGERS = {}

  def self.info(filename, data)
    logger(sanatize(filename)).info(data)
  end

  def self.debug(filename, data)
    logger(sanatize(filename)).debug(data)
  end

  def self.error(filename, data)
    logger(sanatize(filename)).error(data)
  end

  def self.warn(filename, data)
    logger(sanatize(filename)).warn(data)
  end

  def self.fatal(filename, data)
    logger(sanatize(filename)).fatal(data)
  end

  def self.unknown(filename, data)
    logger(sanatize(filename)).unknown(data)
  end

  def self.sanatize(filename)
    filename = "#{filename}.log" unless filename.ends_with?(".log")
    filename
  end

  def self.logger(filename)
    filename = sanatize(filename)
    LOGGERS[filename] ||= LogStashLogger.new(type: :file, path: "log/#{filename}", sync: true)
  end

  def initialize(filename)
    self.filename = filename
  end

  def merge(hash)
    data.merge!(LogSanitizer.sanitize(hash))
  end

  def data
    @data ||= {}
  end

  def log!(type: :info)
    return unless data.present?

    debugger
    self.class.logger(filename).send(type, data)
  end

end