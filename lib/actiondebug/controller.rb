module ActionDebug
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      def filters_for_self
        @filters_for_self ||= _process_action_callbacks
      end

      # With current knowledge of Rails internals, we are going to have to call
      # this method several times when building up a map of the entire
      # application.
      def filters(p = {})
        if p[:action].nil?
          action_methods(false).reduce({}) do |h, action|
            h[action.to_sym] = filters_for_action(action, p)
            h
          end
        else
          {p[:action].to_sym => filters_for_action(p[:action], p)}
        end
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

      def filters_for_self_and_descendents(p = {})
        [self, list_descendants].flatten.reduce({}) do |h, d|
          h[d.name.to_sym] = d.send(:filters, p)
          h
        end
      end

      def before_filters_for_self_and_descendents
        filters_for_self_and_descendents({kind: :before})
      end

      def around_filters_for_self_and_descendents(p = {})
        filters_for_self_and_descendents({kind: :around})
      end

      def after_filters_for_self_and_descendents
        filters_for_self_and_descendents({kind: :after})
      end

      def list_descendants
        Rails.application.eager_load! if Rails.env != "production"
        descendants
      end

      # FIXME: what about filters with the same name in different controllers?
      def actions_skipping_filter(filter)
        raise filter_dne(filter) if !filters.include?(filter.to_sym)
        filters_for_self_and_descendents.reduce({}) do |h, tuple|
          h[tuple.first] = tuple.last.keys.select do |action|
            !tuple.last[action].include?(filter.to_sym)
          end
          h
        end.keep_if { |key, val| !val.empty? }
      end

      # FIXME: what about filters with the same name in different controllers?
      def actions_using_filter(filter)
        raise filter_dne(filter) if !filters.include?(filter.to_sym)
        filters_for_self_and_descendents.reduce({}) do |h, tuple|
          h[tuple.first] = tuple.last.keys.select do |action|
            tuple.last[action].include?(filter.to_sym)
          end
          h
        end.keep_if { |key, val| !val.empty? }
      end

      # This is just like action_methods found in the AbstractController class,
      # but we provide the option to not include inherited methods
      def action_methods(include_ans = true)
        methods = super()
        methods & public_instance_methods(false).map(&:to_s) unless include_ans
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

      def filters_for_action(action, p)
        filters_for_self.select do |c|
          filter_for_kind?(c, p[:kind]) and filter_runs_for_action?(c, action)
        end.map(&:filter)
      end

      def filter_dne(filter)
        "The filter #{filter} does not exist."
      end
    end
  end
end
