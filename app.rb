require 'sinatras-hat'

require 'model'

class Cart < Sinatra::Base
  get '/' do
   'Hello, world!'
  end
  
  mount Item do
    finder {|model, params| model.all}
    record {|model, params| model.get params[:id]}
  end
  
  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end