# g -> Group
# m -> Operator : And / Or
# c -> Condition
# a -> Attribute
# p -> Predicate
# v -> Value
# {
#   "g": {
#     "0": {
#       "m": "and",
#       "c": {
#         "0": {
#           "a": {"0": {"name": "invoice_number"}},
#           "p": "cont",
#           "v": {"0": {"value": "001"}}
#         }
#       }
#     }
#   }
# }

# {
#   g: {
#     0: {
#       m: "and",
#       c: {
#         0: {
#           a: {0: {name: "first_name"}},
#           p: "cont",
#           v: {0: {value: "A"}}
#         },
#         1: {
#           a: {0: {name: "last_name"}},
#           p: "cont",
#           v: {1: {value: "B"}}
#         },
#         2: {
#           m: "or",
#           c: {
#             0: {

#             },
#             1: {

#             }
#           }
#         }
#       }
#     },
#     {
#       m: "or",
#       c: {
#         0: {

#         },
#         1: {

#         }
#       }
#     }
#   }
# }

class Filters::Schema::Validation
  extend Dry::Monads[:result]

  # Fixme: Not validating filters unless the params has "g" attribute
  def self.check(params)
    return Success() unless params&.dig(:g).present?

    errors = {g: {}}
    has_errors = false
    params[:g].each do |position, value|
      e = check_group(value)
      if e.present?
        has_errors = true
        errors[:g][position] = e
      end
    end
    has_errors ? Failure(errors) : Success()
  end

  protected

  class GroupSchema < Transactions::Schema
    params do
      required(:m).filled(inclusion?: %w(and or))
      required(:c).hash
    end
  end

  class ConditionSchema < Transactions::Schema
    params do
      required(:a).hash
      required(:p).filled
      required(:v).hash
    end

    PREDICATES = Rules::Constants::PREDICATES

    # PREDICATES = %w(
    #   eq eq_any eq_all
    #   not_eq not_eq_any not_eq_all
    #   matches matches_any matches_all
    #   does_not_match does_not_match_any does_not_match_all
    #   lt lt_any lt_all
    #   lteq lteq_any lteq_all
    #   gt gt_any gt_all
    #   gteq gteq_any gteq_all
    #   in in_any in_all
    #   not_in not_in_any not_in_all
    #   cont cont_any cont_all
    #   not_cont not_cont_any not_cont_all
    #   start start_any start_all
    #   not_start not_start_any not_start_all
    #   end end_any end_all
    #   not_end not_end_any not_end_all
    #   true
    #   false
    #   present
    #   blank
    #   null
    #   not_null
    # )

    rule :p do
      unless PREDICATES.include?(value)
        key.failure 'Invalid predicate'
      end
    end

    rule :p do
      if %w(true false).include?(value)
        unless values[:v].blank?
          key.failure 'invalid value'
        end
      else
        if values[:v].blank?
          key.failure 'invalid value'
        end
      end
    end

  end

  class AttributeSchema < Transactions::Schema
    params do
      required(:name).filled
    end
  end

  class ValueSchema < Transactions::Schema
    params do
      required(:value).filled
    end
  end

  def self.group_schema
    @group_schema ||= GroupSchema.new
  end

  def self.condition_schema
    @condition_schema ||= ConditionSchema.new
  end

  def self.attribute_schema
    @attribute_schema ||= AttributeSchema.new
  end

  def self.value_schema
    @value_schema ||= ValueSchema.new
  end

  def self.check_group(params)
    result = self.group_schema.(params)
    return result.errors.to_h unless result.success?

    has_errors = false
    errors = {c: {}}
    result[:c].each do |index, condition|
      if %w(and or).include?(condition[:m])
        e = check_group(condition)
      else
        e = check_condition(condition)
      end
      if e.present?
        errors[:c][index] = e
        has_errors = true
      end
    end
    has_errors ? errors : nil
  end

  def self.check_condition(params)
    result = self.condition_schema.(params)
    return result.errors.to_h unless result.success?

    errors = {a: {}, v: {}}
    has_errors = false
    params[:a].each do |index, value|
      e = self.check_attribute(value)
      if e.present?
        errors[:a][index] = e
        has_errors = true
      end
    end

    params[:v].each do |index, value|
      e = self.check_value(value)
      if e.present?
        errors[:v][index] = e
        has_errors = true
      end
    end
    has_errors ? errors : nil
  end

  def self.check_attribute(params)
    result = self.attribute_schema.(params)
    result.success? ? nil : result.errors.to_h
  end

  def self.check_value(params)
    result = self.value_schema.(params)
    result.success? ? nil : result.errors.to_h
  end

end