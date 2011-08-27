class TimeController < ApplicationController
  def index
    calendar_client = GData::Client::Calendar.new
    calendar_client.clientlogin('sacha@sachachua.com', 'Sbj9ork12!!')
  end
end
