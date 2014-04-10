module ActionDebug
  class Railtie < Rails::Railtie
    initializer "actiondebug.action_controller" do
      ActiveSupport.on_load(:action_controller) do
        puts "Extending #{self} with ActionDebug"
        include ActionDebug::Controller
      end
    end
  end
end
