class Message < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 50 }
  validates :number, :phone_number_is_valid, presence: true, length: { maximum: 16 } #15 digits plus 1 for the +

  # max of 160 minus the 38 chars in "Sent from your Twilio trial account - "
  validates :content, presence: true, length: { maximum: 122 } # max of 160 minus the 38 characters in "

  def phone_number_is_valid
    begin
      #response = twilio_lookup_client.phone_numbers.get(:number)
      response = twilio_lookup_client.phone_numbers.get(number)
      response.phone_number
    rescue Twilio::REST::RequestError => e
      if e.code == 20404  #invalid number
        #raise "Invalid number!"
        errors.add(:number, "must be a valid phone number")
      else
        #raise e
        errors.add(:number, "something went horribly wrong with twilio")
      end
    end
  end

  def send_message
    twilio_client.messages.create(
      to: number,
      from: ENV['TWILIO_PHONE_NUMBER'],
      body: content
    )
  end
end

def twilio_client
  Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
end

def twilio_lookup_client
  Twilio::REST::LookupsClient.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
end
