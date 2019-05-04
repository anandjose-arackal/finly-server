class ExpressionEvaluator::Transformer
  attr_accessor :parser

  def self.call(string, data=nil)
    self.new.process(string, data)
  end

  def initialize
    self.parser = ExpressionEvaluator::Parser.new
  end

  def process(string, data=nil)
    # begin
      map = self.parser.parse(string)
    # rescue Parslet::ParseFailed
    #   return nil
    # end
    str_builder = ''
    map.each do |part|
      # begin
        string = ''
        if part[:text].present?
          string = part[:text] || ''
        elsif part[:equation].present?
          equations = part[:equation]

          equation = equations.shift
          object = ExpressionEvaluator::Provider.for(equation[:method], data)
          object = solve(object, equation)
          next if object.nil?

          equations.each do |eq|
            next if object.nil?
            object = solve(object, eq)
          end
          string = object&.data
        else
          # todo math operations
        end
        str_builder += string if string.present?
      # rescue Exception
      #   next
      # end
    end
    str_builder
  end

  protected

  def solve(object, equation)
    method = equation[:method]
    options = {}
    options[:args] = equation[:args]
    object.send(method, options)
  end

end