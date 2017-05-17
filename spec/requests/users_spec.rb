require "rails_helper"

RSpec.describe "User API", :type => :request do

  # :users is a list of 10 users created with FactoryGirl
  # has to be "create_list" because we need them to have IDs
  let!(:users) { create_list(:user, 10) }
  # This user ID definitely exists
  let(:user_id) { users.first.id }

  let(:example_user) {users.first}

  # I need some existing auth_tokens
  let!(:auth_tokens) {create_list(:auth_token, 10)}
  # This one definitely will exist
  let(:existing_auth_token) {{uuid: auth_tokens.first.uuid, secret_token: auth_tokens.first.secret_token}}
  
  describe "GET /users" do 
    before { get '/users' }

    it "returns all users" do 
        expect(JSON.parse(response.body)).not_to be_empty
    end

    it 'returns HTTP 200 OK' do
        expect(response).to have_http_status(200)
    end
  end

  # TODO+AUTH
  describe 'POST /users' do
    # valid payload
    #let(:valid_params) { {user: {name: 'jan', surname: 'skowronka', hobby: 'ruby'}, auth: {uuid: "elo", secret_token: "siema"}} }

    context 'when everything is fine and the user is created' do
      valid_user = {name: Faker::Name.first_name, surname: Faker::Name.last_name, hobby: Faker::Beer.name}
      #before { post '/users', params: {user: valid_user, auth: existing_auth_token} }
      before { post '/users', params: valid_user.merge(existing_auth_token) }

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
      before { post '/users', params: invalid_user.merge(existing_auth_token)}

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
      let(:existing_auth_token) { {uuid: SecureRandom.uuid, secret_token: "There's no way such a token could exist."} }
      before { post '/users', params: valid_user.merge(existing_auth_token) }

      it 'returns 403 Forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'returns a "User invalid." message' do
        expect(JSON.parse(response.body)['error']).to match("Auth data invalid.")
      end

    end

  end

  describe 'PUT /user/:id' do

    new_user_data = {name: "New", surname: "Guy", hobby: "hardcoded strings"}

    context 'when everything is fine and the record is modified' do

      before do
        put "/users/#{user_id}", params: new_user_data.merge(existing_auth_token)
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

      let(:existing_auth_token) { {uuid: SecureRandom.uuid, secret_token: "There's no way such a token could exist."} }

      before do
        put "/users/#{user_id}", params: new_user_data.merge(existing_auth_token)
      end

      it 'returns HTTP 403 Forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'does not change user data' do
        expect(User.find(user_id).name).not_to eq(new_user_data[:name])
        expect(User.find(user_id).surname).not_to eq(new_user_data[:surname])
        expect(User.find(user_id).hobby).not_to eq(new_user_data[:hobby])
      end

    end

    context 'when bad data is supplied' do
    end

  end

  describe 'GET /users/:id' do
    before { get "/users/#{user_id}" }

    context 'when that record exists' do
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

    context "when that record doesn't exist" do
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