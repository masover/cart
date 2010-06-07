require 'sinatras-hat'

require 'model'

class CartDemo < Sinatra::Base
  enable :sessions
  
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
    ''
  end
  
  get '/cleanup_carts' do
    # Carts left unattended for over an hour will be destroyed.
    Cart.all(:state => 'browse', :updated_at.lt => (Time.now - 3600)).each(&:destroy)
    ''
  end
  
  delete '/carts/:id/transactions' do |id|
    key = AppEngine::Datastore::Key.new id
    if Cart.get(key).nil?
      t = ItemTransaction.first :cart_id => key
      return if t.nil?
      found = false
      t.transaction do
        t.reload
        unless t.nil?
          parent = t.parent
          parent.stock += t.count
          parent.save
          t.destroy
          found = true
        end
      end
      if found
        # re-enqueue
        Cart.rollback_transactions_for id
      end
    end
  end
  
  get '/cleanup_transactions' do
    ItemTransaction.all(:order => [ :updated_at.asc ]).each do |transaction|
      if transaction.cart.nil?
        Cart.rollback_transactions_for transaction.cart_id
      elsif transaction.cart.state == 'complete'
        cart_item = transaction.cart.cart_items.first(:item_id => item.id)
        count = cart_item.nil? ? 0 : cart_item.count
        transaction.parent.update_transaction! transaction.cart, count
      end
    end
    ''
  end
  
  get '/cart' do
    haml :cart
  end
  
  delete '/cart' do
    cart = session[:cart]
    cart = Cart.from_param(cart) unless cart.nil?
    unless cart.nil?
      cart.destroy
      session.delete :cart
    end
    redirect '/'
  end
  
  put '/cart/:item' do
    item = Item.from_param params[:item]
    if (count = params[:count]).nil?
      cart!.add_item! item
    else
      cart!.set_item! item, count.to_i
    end
    redirect '/cart'
  end
  
  put '/cart' do
    if params[:state] == 'checkout'
      cart.checkout!
      session.delete :cart
    end
    redirect '/'
  end
  
  def cart
    return @cart unless @cart.nil?
    @cart = session[:cart]
    @cart = Cart.from_param(@cart) unless @cart.nil?
    @cart
  end
  
  def cart!
    if cart.nil?
      session[:cart] = (@cart = Cart.create).id
    end
    cart
  end
  
  # Hack. This is only needed for item index.
  before do
    cart! unless env['HTTP_X_APPENGINE_CRON'] == 'true'
  end
  
end
