class Transactions::Contracts::PreProcessors::SkipDestroy < Transactions::Contracts::PreProcessors::Base

  register!

  def run!
    return false unless (model = options[:populate_if_empty]).present?

    if model and not StringUtils.to_bool(options[:skip_destroy])
      options[:populator] = -> (collection:, fragment:, index:, options:, **) do
        item = collection.find { |item| [fragment["id"].to_s, fragment["uuid"].to_s].include?(item.id.to_s) }

        if fragment["_destroy"]
          collection.destroy(item) if item
          return skip!
        end

        item ? item : collection.append(model.new)
      end
    end
    true
  end

end
