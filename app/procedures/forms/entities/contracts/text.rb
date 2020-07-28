class Forms::Entities::Contracts::Text < Forms::Entities::Contracts::Default
  property :options

  validate :options, :text_options

  def text_options(*args)
    self.model.class.options.values.map(&:keys).map(&:first)
    errors.add(:opptions, "Invalid Options")
  end
end
