require 'rails_helper'

RSpec.describe User, type: :model do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:surname) }
  # Teoretycznie uzytkownik nie musi miec hobby, ale zakladam, ze kazdy sie czyms interesuje.
  it { should validate_presence_of(:hobby) }

end
