class SearchIndex::GenerateToken < Transactions::API

  pass :generate_token

  def generate_token(context, current_user:, **)
    context[:token] = current_user.build_search_index_token
  end

end