module Rules::Predicates

  class Predicate
    attr_accessor :name, :any, :all, :block

    def initialize(params)
      self.name = params[:name]
      self.any = params[:any] || false
      self.all = params[:all] || false
      self.block = params[:block]
    end
  end

  def self.is_number?(value)
    value = [value] unless value.respond_to?(:each)
    value.each do |val|
      is_number = Float(val) rescue false
      return false unless is_number
    end

    true
  end

  def self.to_number(arr)
    arr.map {|val|
      if val.respond_to?(:strftime)
        val.strftime("%s").to_f
      else
        val.to_f
      end
    }
  end

  def self.predicates
    @predicates ||= {}.with_indifferent_access
  end

  def self.predicate(name, any: true, all: true, &block)
    predicates[name] = Predicate.new(name: name, any: any, all: all, block: block)
  end

  def self.setup
    predicates.each_pair do |name, predicate|
      block = predicate.block
      JSONLogic.add_operation name, ->(v, d) do
        block.call(v, d)
      end
      if predicate.any
        JSONLogic.add_operation "#{name}_any", ->(v, d) do
          input = v[0]
          rule_value = v[1]
          rule_value = [rule_value] unless rule_value.respond_to?(:each)
          rule_value.each do |val|
            return true if block.call([input, val], d)
          end
          false
        end
      end
      if predicate.all
        JSONLogic.add_operation "#{name}_all", ->(v, d) do
          input = v[0]
          rule_value = v[1]
          rule_value = [rule_value] unless rule_value.respond_to?(:each)
          rule_value.each do |val|
            return false unless block.call([input, val], d)
          end
          true
        end
      end
    end
  end

  predicate :eq, any: true, all: true do |v, d|
    if Rules::Predicates.is_number?(v)
      v[0]&.to_f == v[1]&.to_f
    else
      v[0]&.to_s&.downcase == v[1]&.to_s&.downcase
    end
    # v[0]&.to_s&.downcase == v[1].to_s.downcase
  end

  predicate :not_eq, any: true, all: true do |v, d|
    v[0]&.to_s&.downcase != v[1].to_s.downcase
  end

  # Todo Matches is Regex search
  # predicate :matches do |v, d|
  #   v[0]&.include?(v[1])
  # end
  #
  # predicate :does_not_match do |v, d|
  #
  # end

  predicate :lt do |v, d|
    Rules::Predicates.to_number(v).each_cons(2).all? { |i, j| i < j }
    # v.map(&:to_f).each_cons(2).all? { |i, j| i < j }
  end

  predicate :lteq do |v, d|
    Rules::Predicates.to_number(v).each_cons(2).all? { |i, j| i <= j }
  end

  predicate :gt do |v, d|
    Rules::Predicates.to_number(v).each_cons(2).all? { |i, j| i > j }
  end

  predicate :gteq do |v, d|
    Rules::Predicates.to_number(v).each_cons(2).all? { |i, j| i >= j }
  end

  # Fixme: check if in is really required as it is is covered by eq_any case in the context of form rules
  # predicate :in, list: true do |v, d|
  #   v[1] = [v[1]] unless v[1].respond_to?(:each)
  #   v[1].include?(v[0])
  # end

  # Fixme: check if not_in is really required as it is is covered by not_eq_all case in the context of form rules
  # predicate :not_in, list: true do |v, d|
  #   !v[1].include?(v[0])
  # end

  predicate :cont, any: true, all: true do |v, d|
    v[0].to_s.include?(v[1].to_s)
  end

  predicate :not_cont, any: true, all: true do |v, d|
    !v[0].to_s.include?(v[1].to_s)
  end

  predicate :start do |v, d|
    v[0].to_s.start_with?(v[1])
  end

  predicate :not_start do |v, d|
    !v[0].to_s.start_with?(v[1])
  end

  predicate :end do |v, d|
    v[0].to_s.end_with?(v[1].to_s)
  end

  predicate :not_end do |v, d|
    !v[0].to_s.end_with?(v[1].to_s)
  end

  predicate :true do |v, d|
    StringUtils::TRUE_VALUES.include?(v[0])
  end

  predicate :false do |v, d|
    StringUtils::FALSE_VALUES.include?(v[0])
  end

  predicate :present do |v, d|
    v[0].present?
  end

  predicate :blank do |v, d|
    v[0].blank?
  end

  predicate :null do |v, d|
    v[0].nil?
  end

  predicate :not_null do |v, d|
    !v[0].nil?
  end

end