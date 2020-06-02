class Transactions::Contracts::PreProcessors::SkipDestroy < Transactions::Contracts::PreProcessors::Base

  register!

  def run!
    return false unless (model_klass = options[:populate_if_empty]).present?

    name = self.name
    if model_klass and not StringUtils.to_bool(options[:skip_destroy])
      options[:populator] = -> (model: nil, collection:, fragment:, index: nil, options:, **) do
        if collection && collection.respond_to?(:find)
          item = collection.find {|item| [fragment["id"], fragment[:id], fragment["uuid"], fragment[:uuid]].compact.map(&:to_s).include?(item.id.to_s)}

          if fragment["_destroy"]
            collection.destroy(item) if item
            return skip!
          end

          item ? item : collection.append(model_klass.new)
        else
          model || self.send("#{name}=", model_klass.new)
        end
      end
    end
    true
  end

end
