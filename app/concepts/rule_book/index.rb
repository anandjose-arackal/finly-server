module RuleBook::Index

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Alias class method for observers_path
    def rules_path(path)
      self.observers_path path
    end
  end

end