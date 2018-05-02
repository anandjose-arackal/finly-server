json.categories do
  json.array!(@result.categories.roots) do |category|
    json.id category.id
    json.name category.name
    if category.children.present?
      json.array!(category.children) do |sub_category|
        json.id sub_category.id
        json.name sub_category.name
      end
    end
  end
end