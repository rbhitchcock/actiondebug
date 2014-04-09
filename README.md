# actioncontroller_filter_chain
A gem to show coverage of ```before_filter```s, ```around_filter```s, and ```after_filter```s for Rails controllers.

# Examples
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

## Show all actions and filters for controllers which inherit from a controller (including itself)
ApplicationController.filters_for_self_and_descendants
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
SessionsController.filters
# => {
#      :index => [:refresh_session],
#      :create => [:refresh_session, :destroy_session],
#      :new => [:refresh_session, :udpate_session],
#      :active => [:require_login, :refresh_session]
#    }

## Show all before filters for a given action
SessionsController.before_filters({action: new})
# => {
#     :new => [:refresh_session, :update_session]
#    }

## Show all actions which skip a given filter, scoped to self and descendants
ApplicationController.actions_skipping_filter(:require_login)
# => {
#      :SessionsController => [:index, :new, :create]
#    }
```

# Installation
## Using Bundler
```
# From https://rubygems.org
gem 'actioncontroller_filter_chain', '~> 1.0.0'

# From github
gem 'actioncontroller_filter_chain', '~> 1.0.0', git: "https://github.com/rbhitchcock/actioncontroller_filter_chain"
```

## Standalone Gem
```
gem -v '1.0.0' actioncontroller_filter_chain
```

## From source
```
> git clone https://github.com/rbhitchcock/actioncontroller_filter_chain.git
> cd actioncontroller_filter_chain
> rake install
```
