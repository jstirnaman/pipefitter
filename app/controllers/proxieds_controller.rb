class ProxiedsController < ApplicationController
  include Ezproxy #api/ezproxy.rb
  
  respond_to do |format|
    format.html
    format.json
    format.jsonp
    format.xml
  end
  
  def initialize
    @api_client = api_client
  end
  
  def api_client(api = :ezproxy, options = {})
    case api
      when :ezproxy
        ezproxy_client
    end  
  end
  
  def ezproxy_client
    @ezproxy_client = Ezproxy::Client.new
  end

  def index
    @query = params[:q] || '.*'
    # Accept string or regexp. If string, convert to regexp.
    query = @query.class == Regexp ? @query : %r/^#{@query}/i
    #Returns links that have text_value matching the query, e.g. find("pubmed")
    #Array of Mechanize::Page::Links objects
    @proxied = api_client.links({:text => query})
  end
  
  def show
    @query = params[:q]
    query = %r/^#{@query}$/i
    @proxied = api_client.links({:text => query})
  end
  
  def api(params)
    supported_apis = [:ezproxy] # Use some validator for this?
    if supported_apis.include?(params[:api].to_sym) 
      api = params[:api]
    end
  end
end

