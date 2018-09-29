class ExpressionEvaluator::Parser < Parslet::Parser

  # Single character rules
  rule(:non_curly_text) {match(/^[^{}]/).repeat(1)}
  rule(:non_paren_text) {match(/^[^()]/).repeat(1)}
  rule(:text?) {text.maybe}
  rule(:method_format) {match['a-zA-Z0-9_-'].repeat(1)}
  rule(:space) {match('\s').repeat(1)}
  rule(:space?) {space.maybe}
  rule(:curly_open) {str('{') >> space?}
  rule(:dot) {str('.') >> space?}
  rule(:curly_close) {space? >> str('}')}
  rule(:lparen) {str('(') >> space?}
  rule(:rparen) {space? >> str(')')}

  # Grammar parts
  rule(:params) {lparen >> non_paren_text.as(:args) >> rparen}
  rule(:function) {(method_format.as(:method) >> params.maybe >> dot.maybe).repeat(1)}
  rule(:equation) {curly_open >> function >> curly_close}

  rule(:expression) {(non_curly_text.as(:text) | equation.as(:equation)).repeat(0)}
  root :expression

end