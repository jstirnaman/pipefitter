class SelectedResourcesController < ApplicationController
  make_resourceful do
    actions :all
  end
  
  respond_to do |format|
    format.html
    format.json
    format.jsonp
    format.xml
  end
  
  # Need to include make_resourceful
  
#   before :index do
#     @current_objects = current_objects 
#     
#     if params[:q]
#       @resources = SelectedResource.find_all(params[:field], params[:q])
#     end
#   end
#   
#   before :show do
#     if params[:q]
#       @resource = SelectedResource.find(params[:field], params[:q])
#     else
#     end
#     
#     # Collect and display data about this resource from all other services
#     @resource.has_marc
#     
#     @resource.has_kb_holdings
#     
#     @resource.has_proxy
#   end
#   
#   def index
# 
#   end
#   
#   def show
#  
#   end

  
end

