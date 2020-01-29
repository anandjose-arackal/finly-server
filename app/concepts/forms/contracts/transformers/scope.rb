class Forms::Contracts::Transformers::Scope < Forms::Contracts::Transformers::Base

  register :scope

  def transform!
    return unless value

    if value[:enum]
      validate_enum
    elsif value[:choices]
      validate_choices
    elsif value[:auto_complete]
      validate_auto_complete
    elsif value[:resolver]
      validate_resolver
    end
    # validates << [name, presence: true]
  end

  def validate_enum

  end

  def validate_choices

  end

  def validate_auto_complete

  end

  def validate_resolver

  end



end