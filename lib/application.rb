class Application < NonPersistentModel

  def self.values
    ['em', 'vp', 'ft', 'ap']
  end

  def eager_load! #:nodoc:
    railties.all(&:eager_load!)
    super
  end

  def self.id_for(app)
    case app
      when :expense_management, :em
        return :em
      when :vendor_payment, :vp
        return :vp
      when :fund_transfer, :ft
        return :ft
      when :admin_panel, :ap
        return :ap
      else
        return nil
    end
  end

  def self.validate_app(options = {})
    if options[:presence].nil?
      options[:presence] = true
    end
    if options[:inclusion].nil?
      options[:inclusion] = { :in => Application.values}
    end
    options
  end

end