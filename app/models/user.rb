class User < ApplicationRecord
    # Teoretycznie uzytkownik nie musi miec hobby, ale zakladam, ze kazdy sie czyms interesuje.
    validates_presence_of :name, :surname, :hobby
end
