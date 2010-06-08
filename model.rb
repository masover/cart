require 'extlib'
%w(Item Base Cart CartItem ItemTransaction ItemUpdateKey).each do |model|
  autoload model.to_sym, "model/#{model.snake_case}"
end