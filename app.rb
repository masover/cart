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
    # Consider them stale after one minute. They should only be in this state if the
    # request previously handled them has already died.
    Cart.all(:state => 'checkout', :updated_at.lt => (Time.now - 60)).each(&:checkout!)
  end
  
end
