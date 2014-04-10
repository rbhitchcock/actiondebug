# actiondebug
A gem to show which *_filters affect your Rails controllers. Useful for security
research (which controllers and actions skip an auth check?) and debugging
development problems (why isn't a method running for a given request?)

# Examples

### Sample Application
```ruby
class ApplicationController < ActionController::Base
  before_filter :require_login
  before_filter :refresh_session

  def index
  end

  private
  def require_login
  end

  def refresh_session
  end
end

class SessionsController < ApplicationController
  skip_before_filter :require_login, :except => :active
  before_filter :update_session, :only => :create
  before_filter :destroy_session, :only => :new

  def index
  end

  def new
  end

  def create
  end

  def active
  end

  private
  def udpate_session
  end

  def destroy_session
  end
end
```

### Commands in Rails Console
```ruby
## Show all actions and filters for controllers which inherit from a controller (including itself)
> ApplicationController.filters_for_self_and_descendants
# => {
#     :ApplicationController => {:index => [:require_login, :refresh_session]},
#     :SessionsController => {
#                              :index => [:refresh_sesion],
#                              :new => [:refresh_session, :destroy_session],
#                              :create => [:refresh_session, :update_session],
#                              :active => [:require_login, :refresh_session]
#                            }
#    }

## Show all filters used by a controller
> SessionsController.filters
# => {
#      :index => [:refresh_session],
#      :create => [:refresh_session, :destroy_session],
#      :new => [:refresh_session, :udpate_session],
#      :active => [:require_login, :refresh_session]
#    }

## Show all before filters for a given action
> SessionsController.before_filters(:new)
# => {
#     :new => [:refresh_session, :update_session]
#    }

## Show all actions which skip a given filter, scoped to self and descendants
> ApplicationController.actions_skipping_filter(:require_login)
# => {
#      :SessionsController => [:index, :new, :create]
#    }
```

# Installation
## Using Bundler
```
# From https://rubygems.org
gem 'actiondebug', '~> 1.0.0'

# From github
gem 'actiondebug', '~> 1.0.0', git: "https://github.com/rbhitchcock/actiondebug"
```

## Standalone Gem
```
gem -v '1.0.0' actiondebug
```

## From source
```
> git clone https://github.com/rbhitchcock/actiondebug.git
> cd actiondebug
> rake install
```
