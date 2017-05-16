class AuthToken < ApplicationRecord
	validates_presence_of :uuid, :secret_token
end
