class EnrichmentsController < ApplicationController
  include Ditare 

  def index
		@field = params[:field] || 'database_name'
		@query = params[:q] || '.*'
		@enrichments = []
		@es = Ditare::EnrichmentSet.new({:field => @field, :q => @query})
		@es.recordset.each do |r|
      # Convert GData object to hash
      @enrichments << [Hash.try_convert(r)]
    end
    @enrichments
  end
 
end

