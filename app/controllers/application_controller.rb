class ApplicationController < ActionController::Base
  protect_from_forgery
  
  layout "application"
  
  respond_to do |format|
    format.html
    format.json
    format.jsonp
    format.xml
  end

end
