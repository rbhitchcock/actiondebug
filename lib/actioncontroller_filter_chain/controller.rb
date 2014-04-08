module ActionControllerFilterChain
  module Controller
    extend ActiveSupport::Concern

    included do
      class_attribute :filters_for_self, instance_writer: false, instance_reader: false
    end

    module ClassMethods
      # With current knowledge of Rails internals, we are going to have to call
      # this method several times when building up a map of the entire
      # application. Use a class attribute to make it as efficient as possible.
      def filters(p = {})
        @filters_for_self ||= _process_action_callbacks
        @filters_for_self.select do |c|
          filter_for_kind?(c, p[:kind]) and filter_runs_for_action?(c, p[:action])
        end.map(&:filter)
      end

      def before_filters(action = nil)
        filters kind: :before, action: action
      end

      def around_filters(action = nil)
        filters kind: :around, action: action
      end

      def after_filters(action = nil)
        filters kind: :after, action: action
      end

      def show_filters_for_self_and_descendents(p = {})
        [self, list_descendants].flatten.reduce({}) do |h, descendant|
          h[descendant.name.to_sym] = descendant.send(:action_methods).reduce({}) do |h, action|
            p[:action] = action.to_sym
            h[action.to_sym] = filters p
            h
          end
          h
        end
      end

      def show_before_filters_for_self_and_descendents
        show_filters_for_self_and_descendents({kind: :before})
      end

      def show_around_filters_for_self_and_descendents(p = {})
        show_filters_for_self_and_descendents({kind: :around})
      end

      def show_after_filters_for_self_and_descendents
        show_filters_for_self_and_descendents({kind: :after})
      end

      def list_descendants
        Rails.application.eager_load! if Rails.env != "production"
        descendants
      end

      private

      def filter_for_kind?(filter, kind)
        return true if kind.nil?
        filter.kind == kind
      end

      def filter_runs_for_action?(filter, action)
        return true if action.nil? or filter.per_key.empty?
        # XXX The @per_key attribute used below builds up its conditionals using
        # action_name as the attribute to compare against. I don't like depending
        # on this, but I don't see any way around it. Just keep this in mind if
        # things ever start breaking.
        action_name = action.to_s
        conditions = ["true"]
        unless filter.per_key[:if].empty?
          conditions << Array.wrap("(#{filter.per_key[:if].first})")
        end
        unless filter.per_key[:unless].empty?
          conditions << Array.wrap("!(#{filter.per_key[:unless].first})")
        end
        # XXX I feel safe using eval because we are only accessing Rails internal
        # stuff, but try to come up with a better way to do this in the future if
        # possible.
        eval conditions.flatten.join(" && ")
      end
    end
  end
end
