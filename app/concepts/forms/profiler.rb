class Forms::Profiler

  attr_accessor :start_time, :end_time, :duration, :running_step, :parent, :depth, :id, :tags

  def initialize(params, &block)
    params.each_pair do |k, v|
      self.send("#{k}=", v)
    end
    self.depth = parent.present? ? parent.depth + 1 : 0

    if block_given?
      return monitor(&block)
    end

    nil
  end

  def monitor(&block)
    return unless block_given?

    start!
    result = block.call
    end!

    result
  end

  def start!
    return unless self.start_time.blank? and self.end_time.blank?

    self.start_time = Time.now
  end

  def end!
    return unless self.start_time.present? and self.end_time.blank?

    self.end_time = Time.now
    self.duration = self.end_time - self.start_time
  end

  def steps
    @steps ||= []
  end

  def step(id, *tags, &block)
    if running_step.present?
      result = running_step.step(id, *tags, &block)
    else
      step = Forms::Profiler.new(parent: self, id: id, tags: tags)
      steps << step
      self.running_step = step
      result = step.monitor(&block)
      self.running_step = nil
    end
    result
  end

  def stats(mode = :summary)
    case mode
    when :summary
      Summarizer.(self)
    else
      Summarizer.(self)
    end
  end

  class Summarizer

    def self.call(profiler)
      puts "=>"
      build_summary(profiler).each_pair do |id, data|
        print_summary id, data
      end

      nil
    end

    def self.print_summary(id, data)
      print_text = "##{"  " * data[:depth]} |-- #{data[:duration].round(4)}  #{id}"
      print_text += " (#{data[:iteration]})" if data[:iteration] > 1
      puts  print_text
      if data[:steps].present?
        data[:steps].each do |i, d|
          print_summary i, d
        end
      end
    end

    def self.build_summary(step, data = {})
      data ||= {}
      data[step.id] ||= {duration: 0, depth: step.depth, iteration: 0, steps: {}}
      data[step.id][:duration] += step.duration
      data[step.id][:iteration] += 1
      step.steps.each do |s|
        build_summary(s, data[step.id][:steps])
      end
      data
    end

  end

end