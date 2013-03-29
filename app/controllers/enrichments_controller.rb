class EnrichmentsController < ApplicationController
  include Ditare

  respond_to do |format|
    format.html
    format.json
    format.jsonp
    format.xml
  end
  
  def initialize
    
  end

  def index
		@field = params[:field] || 'database_name'
		@query = params[:q] || '.*'
		@api_client = Ditare::EnrichmentSet.new({:field => @field, :q => @query})
		@enrichments = @api_client.recordset
  end
 
end

