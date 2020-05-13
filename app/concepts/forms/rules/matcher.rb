module Forms::Rules::Matcher

  class Predicate
    attr_accessor :name, :any, :all, :list

    def initialize(params)
      self.name = params[:name]
      self.any = params[:any] || false
      self.all = params[:all] || false
      self.list = params[:list] || false
    end
  end

  def self.predicates
    @predicates ||= {}.with_indifferent_access
  end

  def self.predicate(name, any: true, all: true, list: false, &block)
    predicates[name] = Predicate.new({name: name, any: any, all: all, list: list})
    define_method "match_#{name}?" do |input, rule_value|
      # todo Unsupported predicate
      # return false unless self.class.operators.include?(name)

      # rule_value = [rule_value] if list and not rule_value.respond_to?(:each)
      if rule_value.respond_to?(:each)
        # if rule is array, call _any? condition
        send("match_#{name}_any?", input, rule_value)
      else
        block.call(parse(input), parse(rule_value))
      end
    end
    if any
      define_method "match_#{name}_any?" do |input, rule_value|
        rule_value.each do |val|
          return true if send("match_#{name}?", input, val)
        end
        false
      end
    end
    if all
      define_method "match_#{name}_all?" do |input, rule_value|
        rule_value.each do |val|
          return false unless send("match_#{name}?", input, val)
        end
        true
      end
    end
  end

  def parse(value)
    value.to_s
  end

  predicate :eq, any: true, all: true do |input, rule_value|
    input == rule_value
  end

  predicate :not_eq, any: true, all: true do |input, rule_value|
    input != rule_value
  end

  # Todo Matches is Regex search
  # predicate :matches do |input, rule_value|
  #   input.include?(rule_value)
  # end
  #
  # predicate :does_not_match do |input, rule_value|
  #
  # end

  predicate :lt do |input, rule_value|
    input < rule_value
  end

  predicate :lteq do |input, rule_value|
    input <= rule_value
  end

  predicate :gt do |input, rule_value|
    input > rule_value
  end

  predicate :gteq do |input, rule_value|
    input >= rule_value
  end

  # Fixme: check if in is really required as it is is covered by eq_any case in the context of form rules
  # predicate :in, list: true do |input, rule_value|
  #   rule_value = [rule_value] unless rule_value.respond_to?(:each)
  #   rule_value.include?(input)
  # end
  #
  # Fixme: check if not_in is really required as it is is covered by not_eq_all case in the context of form rules
  # predicate :not_in, list: true do |input, rule_value|
  #   !rule_value.include?(input)
  # end

  predicate :cont, any: true, all: true do |input, rule_value|
    input.include?(rule_value)
  end

  predicate :not_cont, any: true, all: true do |input, rule_value|
    !cont(input, rule_value)
  end

  predicate :start do |input, rule_value|
    input.start_with?(rule_value)
  end

  predicate :not_start do |input, rule_value|
    !input.start_with?(rule_value)
  end

  predicate :end do |input, rule_value|
    input.end_with?(rule_value)
  end

  predicate :not_end do |input, rule_value|
    !input.end_with?(rule_value)
  end

  predicate :true do |input, rule_value|
    StringUtils::TRUE_VALUES.include?(input)
  end

  predicate :false do |input, rule_value|
    StringUtils::FALSE_VALUES.include?(input)
  end

  predicate :present do |input, rule_value|
    input.present?
  end

  predicate :blank do |input, rule_value|
    input.blank?
  end

  predicate :null do |input, rule_value|
    input.null?
  end

  predicate :not_null do |input, rule_value|
    !input.null?
  end

end