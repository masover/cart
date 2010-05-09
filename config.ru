require 'appengine-rack'
AppEngine::Rack.configure_app(
    :application => "cart-demo",
    :precompilation_enabled => true,
    :version => "1")

require 'app'
run Cart
