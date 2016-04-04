class Message < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 50 }
  VALID_NUMBER_REGEX = /\A\+?\d{3,15}\z/  # allow a + up front, require 3-15 digits
  validates :number, presence: true, length: { maximum: 16 },  # 15 digits plus +
                     format: { with: VALID_NUMBER_REGEX }
  validate :phone_number_is_twilio_valid
  validates :from, presence: true, length: { maximum: 16 },
                   format: { with: VALID_NUMBER_REGEX }

  # max of 160 minus the 38 chars in "Sent from your Twilio trial account - "
  validates :content, presence: true, length: { maximum: 122 } # max of 160 minus the 38 characters in "

  def from
    ENV['TWILIO_PHONE_NUMBER']
  end

  def phone_number_is_twilio_valid
    begin
      if number.empty?
        errors.add(:number, "must exist")
      else
        response = twilio_lookup_client.phone_numbers.get(number)
        response.phone_number
      end
    rescue Twilio::REST::RequestError => e
      if e.code == 20404  #invalid number
        errors.add(:number, "must be a valid phone number according to twilio")
      else
        errors.add(:number, "something went horribly wrong with twilio")
      end
    end
  end

  def send_message
    @rejected = false
    begin
      twilio_client.messages.create(
        to: number,
        from: from,
        body: content
      )
    rescue Twilio::REST::RequestError => e
      if e.code == 21608  # trial account
        @rejected = true
        errors.add(:number, "must be validated by twilio because this is a trial account")
      end
    end
  end

  def rejected?
    @rejected
  end
end

def twilio_client
  Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
end

def twilio_lookup_client
  Twilio::REST::LookupsClient.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
end
