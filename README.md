# actioncontroller_filter_chain
A gem to show coverage of ```before_filter```s, ```around_filter```s, and ```after_filter```s for Rails controllers.

# Examples
## Show all actions and filters for controllers which inherit from a controller (including itself)
```ruby
>> ApplicationController.show_filters_for_self_and_descendants
# => {
#     :ApplicationController => {:index => [:filter1, :filter2],
#     :SessionsController => {:index => [:fitler1], :new => [:filter3, filter4]
#    }
```

## Show all filters used by a controller
```ruby
>> SessionsController.filters
# => [:verify_authenticity_token, :require_login, :set_username_cookie]
```

## Show all before filters for a given action
```ruby
>> SessionsController.before_filters(:new)
# => [:verify_authenticity_token, :refresh_session]
```

## Show all actions which skip a given filter
```ruby
>> ApplicationController.actions_skipping_filter(:require_login)
# => {
#      :ApplicationController => [:index],
#      :SessionsController => [:create, :new],
#      :PublicController => [:index, :show, :new, :update, :create, :destroy]
#    }
```
