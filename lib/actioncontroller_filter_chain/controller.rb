module ActionControllerFilterChain
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      def omfg
        puts "WUT"
      end
    end
  end
end
