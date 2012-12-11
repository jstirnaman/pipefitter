class SelectedResource
# Get selected resources from Google Spreadsheet
  include GData
  attr_accessor :recordset
  def initialize(query)
    gdata = GData::Client.new(API_CONFIG['GOOGLE_DRIVE']['ONLINE_RESOURCES_SHEET'])
    @recordset = gdata.worksheet.rows.select { |r| r[0].match(/.*#{query}.*/i) }
  end
  
  def find_in_proxy
    proxy = ResourceProxy.new
    proxied_records = recordset.map do |r| 
      proxy.search(r[0]).first
    end
  end
end