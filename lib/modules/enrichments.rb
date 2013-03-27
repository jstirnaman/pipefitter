module Enrichments
  include GData
  
  def find_all(query_field = 'database_name', query_value)
    client = GData::Client.new(API_CONFIG['GOOGLE_DRIVE']['ONLINE_RESOURCES_SHEET'])
    # Accept string or regexp. If string, convert to regexp.
    query_value = query_value.class == Regexp ? query_value : %r/#{query_value}/i
    # Return an array of matching resources as GoogleDrive::ListRow objects
    #  #<GoogleDrive::ListRow {"database_name"=>"AccessMedicine", 
    #    "local_subjects"=>"Clinical Medicine; Basic Sciences", "oclc_id"=>"51502184"}>
    recordset = client.worksheet.select { |r| r[query_field].match(query_value) }
  end
  
  def find(query_field, query_value)
    # Return only the first matching record.
    find_all(query).first
  end
  
end