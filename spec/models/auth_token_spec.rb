require 'rails_helper'

RSpec.describe AuthToken, type: :model do

    it { should validate_presence_of(:uuid) }
    it { should validate_presence_of(:secret_token) }

end
