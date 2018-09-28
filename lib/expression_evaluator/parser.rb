class ExpressionEvaluator::Parser < Parslet::Parser

  # Single character rules
  rule(:text) {match['[^a-zA-Z0-9/-,\]'].repeat(1)}
  rule(:text?) {text.maybe}
  rule(:string) {match['a-z'].repeat(1)}
  rule(:space) {match('\s').repeat(1)}
  rule(:space?) {space.maybe}
  rule(:curly_open) {str('{') >> space?}
  rule(:curly_close) {space? >> str('}')}
  rule(:lparen) {str('(') >> space?}
  rule(:rparen) {space? >> str(')')}

  # Grammar parts
  rule(:params) {lparen >> text.as(:args) >> rparen}
  rule(:function) {string.as(:method) >> params}
  rule(:equation) {curly_open >> function >> curly_close}

  rule(:expression) {(text.as(:text) | equation.as(:equation)).repeat(0)}
  root :expression

end