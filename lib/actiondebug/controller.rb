module ActionDebug
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
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

      def filters_for_self_and_descendants(p = {})
        [self.name.to_sym, symbolized_descendants].flatten.reduce({}) do |h, d|
          h[d] = safe_instantiate(d).send(:filters, p)
          h
        end
      end

      def before_filters_for_self_and_descendants
        filters_for_self_and_descendants({kind: :before})
      end

      def around_filters_for_self_and_descendants(p = {})
        filters_for_self_and_descendants({kind: :around})
      end

      def after_filters_for_self_and_descendants
        filters_for_self_and_descendants({kind: :after})
      end

      # FIXME: what about filters with the same name in different controllers?
      def actions_skipping_filter(filter)
        filters_for_self_and_descendants.reduce({}) do |h, tuple|
          # We want to handle the false positive of someone supplying a filter
          # that simply does not exist either at all, or for the current
          # controller being analyzed.
          if !safe_instantiate(tuple.first).defined_filters.include?(filter)
            puts "Filter #{filter} is not defined for #{tuple.first.to_s}. Skipping."
            h[tuple.first] = []
          else
            h[tuple.first] = tuple.last.keys.select do |action|
              !tuple.last[action].include?(filter.to_sym)
            end
          end
          h
        end.keep_if { |key, val| !val.empty? }
      end

      # FIXME: what about filters with the same name in different controllers?
      def actions_using_filter(filter)
        filters_for_self_and_descendants.reduce({}) do |h, tuple|
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

      def defined_filters
        @defined_filters ||= filters_for_self.map(&:filter)
      end

      private

      def filters_for_self
        @filters_for_self ||= _process_action_callbacks
      end

      def symbolized_descendants
        @symbolized_descendants ||= symbolize_descendants
      end

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

      def safe_instantiate(klass)
        return self unless is_a_descendant?(klass)
        klass.to_s.constantize
      end

      def symbolize_descendants
        Rails.application.eager_load! if Rails.env != "production"
        descendants.map do |d|
          d.name.to_sym
        end
      end

      def is_a_descendant?(klass)
        symbolized_descendants.include?(klass)
      end
    end
  end
end
