# Get the db list from the web site and print necessary fields to CSV for importing to Google.
# Disposable code. Hopefully, just a one-time thing!
require 'nokogiri'
require 'open-uri'
require 'csv'

module ScrapeDatabases

def dbnames
  # Collect second entry from array.
  build_arr.map {|e| e[1]}
end

def dblinks
  css('tr td a')
end

def to_csv
  csv_string = CSV.generate do |csv|
  css('tr').each do |tr|
    row = []
    tr.css('td').each_with_index do |td, index|
      case index
      when 1 # Database name in second column
      row << td.css('a').text
      when 2 # Database subject in third column
      row << td.text
      end
    end
    csv << row
  end
  end
  csv_string
end


end

# How to use:

# include ScrapeDatabases
# @doc = Nokogiri::HTML(open("http://library.kumc.edu/database-list.xml"))
# @mytable = @doc.css('#myTable')
# @mytable.to_csv



