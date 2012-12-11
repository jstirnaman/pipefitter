# Scrapes your EZProxy /menu page to find the list of configured resources and URLs.
module Ezproxy

  class Client
    include CasMechanizer
    
    attr_accessor :agent, :store, :page

    def initialize()
      @agent = Mechanize.new
      @agent.log = Logger.new "mechanize-ezproxy.log"
      @agent.user_agent_alias = 'Mac FireFox'
      # Store CAS credentials.
      @store = cas_auth_store
      # Return a Mechanize Page object from the content at URL.
      #@page = @agent.get(API_CONFIG['EZPROXY']['BASE_URL']+'/menu')
      @page = mechanize_authentication(API_CONFIG['EZPROXY']['BASE_URL']+'/menu')
    end
    
    def links(options = {:href => %r/proxy.kumc.edu/})
      # Mechanize returns array of matching Mechanize::Page::Link objects with a.content, a.href
      page.links_with(options)
    end

    private

    def format_id_param(id)
      Array(id).join('/')
    end
    
    def hash_from_menu
    # Parse the HTML doc and find the paragraph element containing the list of links.
      #body = doc.css('body')
      #menu = body.xpath("/p[a[contains(@href, '/login?url=')]]")
    end
  end
end