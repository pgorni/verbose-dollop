require "rails_helper"

RSpec.describe "User API", :type => :request do

  # :users is a list of 10 users created with FactoryGirl
  # They're also written to the test DB itself, so they also have proper IDs
  let!(:users) { create_list(:user, 10) }
  # This user ID definitely exists
  let(:user_id) { users.first.id }

  # I need some existing auth_tokens
  let!(:auth_tokens) {create_list(:auth_token, 10)}
  # This one definitely will exist
  let(:example_auth_token) {{uuid: auth_tokens.first.uuid, secret_token: auth_tokens.first.secret_token}}

  # This will become handy in the PUT/PATCH method
  let(:new_user_data) { {name: "New", surname: "Guy", hobby: "hardcoded strings"} }
  
  describe "GET /users" do 
    before { get '/users' }

    it "returns all users" do 
        expect(JSON.parse(response.body)).not_to be_empty
    end

    it 'returns HTTP 200 OK' do
        expect(response).to have_http_status(200)
    end
  end

  describe 'POST /users' do

    context 'when everything is fine and the user is created' do
      valid_user = {name: Faker::Name.first_name, surname: Faker::Name.last_name, hobby: Faker::Beer.name}
      before { post '/users', params: valid_user.merge(example_auth_token) }

      it 'creates an user' do
        json = JSON.parse(response.body)
        expect(json['result']).to eq("User created.")
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the user is invalid' do
      invalid_user = {name: Faker::Name.first_name, hobby: Faker::Beer.name}
      before { post '/users', params: invalid_user.merge(example_auth_token)}

      it 'returns HTTP 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a "User invalid." message and the appropriate messages' do
        expect(response.body).to match("User invalid.")
        expect(JSON.parse(response.body)['messages']).not_to be_empty
      end
    end

    context 'when the user is valid, but auth is incomplete' do
      valid_user = {name: Faker::Name.first_name, surname: Faker::Name.last_name, hobby: Faker::Beer.name}
      # There is uuid, but no secret_token
      before {post '/users', params: valid_user.merge({uuid: SecureRandom.uuid})}

      it 'returns 403 Forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'returns a "Auth data incomplete." and the appropriate messages' do
        expect(JSON.parse(response.body)['error']).to match("Auth data incomplete.")
        expect(JSON.parse(response.body)['messages']).not_to be_empty
      end

    end

    context 'when the user is valid, but auth is invalid' do
      valid_user = {name: Faker::Name.first_name, surname: Faker::Name.last_name, hobby: Faker::Beer.name}
      let(:example_auth_token) { {uuid: SecureRandom.uuid, secret_token: "There's no way such a token could exist."} }
      before { post '/users', params: valid_user.merge(example_auth_token) }

      it 'returns 403 Forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'returns a "Auth data invalid." message' do
        expect(JSON.parse(response.body)['error']).to match("Auth data invalid.")
      end

    end

  end

  describe 'PUT /user/:id' do

    context 'when everything is fine and the record is modified' do

      before do
        put "/users/#{user_id}", params: new_user_data.merge(example_auth_token)
      end

      it 'returns HTTP 200 OK' do
        expect(response).to have_http_status(200)
      end

      it 'changes the user data' do
        expect(User.find(user_id).name).to eq(new_user_data[:name])
        expect(User.find(user_id).surname).to eq(new_user_data[:surname])
        expect(User.find(user_id).hobby).to eq(new_user_data[:hobby])
      end

    end

    context 'when the auth is invalid' do

      let(:example_auth_token) { {uuid: SecureRandom.uuid, secret_token: "There's no way such a token could exist."} }

      before do
        put "/users/#{user_id}", params: new_user_data.merge(example_auth_token)
      end

      it 'returns HTTP 403 Forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'does not change user data' do
        expect(User.find(user_id).name).not_to eq(new_user_data[:name])
        expect(User.find(user_id).surname).not_to eq(new_user_data[:surname])
        expect(User.find(user_id).hobby).not_to eq(new_user_data[:hobby])
      end

      it 'returns a "Auth data invalid." message' do
        expect(JSON.parse(response.body)['error']).to match("Auth data invalid.")
      end

    end

    context 'when there is no user data supplied' do

      before do
        # Not giving the user data at all
        put "/users/#{user_id}", params: example_auth_token
      end

      it 'returns HTTP 400 Bad Request' do
        expect(response).to have_http_status(400)
      end

      it 'returns a "User not modified - no data given." message' do
        expect(JSON.parse(response.body)['error']).to match("User not modified - no data given.")
      end

    end

    context "when that record doesn't exist" do
      # This user won't exist
      let(:user_id) { 100 }

      before do
        put "/users/#{user_id}", params: new_user_data.merge(example_auth_token)
      end

      it 'returns HTTP 404 Not Found' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(JSON.parse(response.body)['error']).to match("User not found.")
      end
    end

  end


  describe 'DELETE /users/:id' do 

    context 'when that user exists and auth is valid' do

      before { delete "/users/#{user_id}", params: example_auth_token}

      it 'deletes the user' do
        expect(User.exists?(user_id)).to eq(false)
      end

      it 'returns HTTP 200 OK' do
        expect(response).to have_http_status(200)
      end

    end

    context 'when auth is invalid' do

      let(:example_auth_token) { {uuid: SecureRandom.uuid, secret_token: "Something you won't find in the database."} }

      before { delete "/users/#{user_id}", params: example_auth_token}

      it 'does not delete the user' do 
        expect(User.exists?(user_id)).to eq(true)
      end

      it 'returns HTTP 403 Forbidden' do
        expect(response).to have_http_status(403)
      end

    end

    context 'when the user does not exist' do

      let(:user_id) { 100 }

      before { delete "/users/#{user_id}", params: example_auth_token}

      it 'returns HTTP 404 Not Found' do
        expect(response).to have_http_status(404)
      end

      it 'returns a "User not found." message' do
        expect(JSON.parse(response.body)['error']).to match("User not found.")
      end

    end

  end

  describe 'GET /users/:id' do
    before { get "/users/#{user_id}" }

    context 'when that user record exists' do
      it 'checks if the required data are supplied' do
        json = JSON.parse(response.body)
        expect(json).not_to be_empty
        expect(json['name']).not_to be_empty
        expect(json['surname']).not_to be_empty
        expect(json['hobby']).not_to be_empty
      end

      it 'returns HTTP 200 OK' do
        expect(response).to have_http_status(200)
      end
    end

    context "when that user record doesn't exist" do
      # This user won't exist
      let(:user_id) { 100 }

      it 'returns HTTP 404 Not Found' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(JSON.parse(response.body)['error']).to match("User not found.")
      end
    end

  end

end