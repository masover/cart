require 'sinatras-hat'

require 'model'

class Cart < Sinatra::Base
  get '/' do
   'Hello, world!'
  end
  
  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
  
  mount Item do
    finder {|model, params| model.all}
    record do |model, params|
      id = params[:id]
      if id.kind_of? String
        id = com.google.appengine.api.datastore.KeyFactory.stringToKey id
      end
      model.get id
    end
  end
end