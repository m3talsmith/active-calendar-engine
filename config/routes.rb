ActionController::Routing::Routes.draw do |map|
  map.resources :calendars
  map.root :controller => "calendars", :action => "index"
end
