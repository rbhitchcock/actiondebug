module ActionControllerFilterChain
  class Railtie < Rails::Railtie
    initializer "controller_filter_chain.action_controller" do
      ActiveSupport.on_load(:action_controller) do
        puts "extending #{self} with Wut::Controller"
        include ActionControllerFilterChain::Controller
      end
    end
  end
end
