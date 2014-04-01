module ActionController
  class Base
    def self.filters(p = {})
      _process_action_callbacks.select do |c|
        filter_for_kind?(c, p[:kind]) and filter_runs_for_action?(c, p[:action])
      end.map(&:filter)
    end

    def self.before_filters(action = nil)
      filters kind: :before, action: action
    end

    def self.around_filters(action = nil)
      filters kind: :around, action: action
    end

    def self.after_filters(action = nil)
      filters kind: :after, action: action
    end

    private

    def self.filter_for_kind?(filter, kind)
      return true if kind.nil?
      filter.kind == kind
    end

    def self.filter_runs_for_action?(filter, action)
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
