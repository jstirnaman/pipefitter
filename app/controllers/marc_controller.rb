class MarcController < ApplicationController
  include Ditare
  
  attr_accessor :client
  
  respond_to do |format|
    format.html
    format.json
    format.jsonp
    format.xml
    format.mrc
  end
  
  def initialize
    @client = Ditare::MarcRecordset::Client.new
  end
  
end