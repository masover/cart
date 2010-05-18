require 'sinatras-hat'

require 'model'

class CartDemo < Sinatra::Base
  get '/' do
    'Hello, world!'
  end
  
  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
  
  mount Item do
    finder {|model, params| model.all}
    record {|model, params| model.from_param params[:id]}
  end
  
  get '/finalize_checkouts' do
    Cart.all(:state => 'checkout').each(&:checkout!)
  end
  
end
