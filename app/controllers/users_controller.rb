class UsersController < ApplicationController
    
    # GET /users
    def index
        @users = User.all
        render json: @users, status: :ok
    end

    # GET /user/:id
    def show

        if User.exists?(params[:id])
            render json: User.find(params[:id]), status: :ok
        else
            render json: {error: "User not found."}, status: :not_found
        end

    end

    def create
        new_user = User.new(params.permit(:name, :surname, :hobby))
        set_auth_data
        @error = {}

        if auth
            # check user
            if new_user.valid?
                new_user.save
                render json: {result: "User created.", user: new_user.as_json}, status: :created
            else
                render json: {error: "User invalid.", messages: new_user.errors.messages}, status: 422
            end
        else
            # this will be an error of some kind
            render json: @error, status: :forbidden
        end
    end

    def update
        set_auth_data

        if auth
            if User.exists?(params[:id])
                
                new_user_data = params.permit(:name, :surname, :hobby)

                unless new_user_data.empty?
                    # update user data
                    user = User.find(params[:id])
                    user.update(new_user_data.to_hash)
                    user.save
                    render json: {result: "User modified."}, status: :ok
                else
                    # don't update user data; new user data hasn't been given
                    render json: {error: "User not modified - no data given."}, status: :bad_request
                end
                
            else
                render json: {error: "User not found."}, status: :not_found
            end
        else
            # this will be an error of some kind
            render json: @error, status: :forbidden
        end

    end

    def destroy
        set_auth_data

        if auth
            if User.exists?(params[:id])
                User.destroy(params[:id])
                render json: {result: "User deleted."}, status: :ok
            else
                render json: {error: "User not found."}, status: :not_found
            end
        else
            # this will be an error of some kind
            render json: @error, status: :forbidden
        end

    end

    private

    def auth

        # this will serve as a shorthand to checking completeness
        auth_data_db_entry = AuthToken.new(@auth_data)

        if auth_data_db_entry.valid? # in terms of completeness
            # we can look up if there's such an entry in the DB
            unless AuthToken.find_by(@auth_data).nil?
                return true
            else
                # the auth data is complete, but invalid
                @error = {error: "Auth data invalid."}
                return false
            end
        else
            #the auth data is incomplete
            @error = {error: "Auth data incomplete.", messages: auth_data_db_entry.errors.messages}
            return false
        end
    end

    def set_auth_data
        @auth_data = params.permit(:uuid, :secret_token)
    end

end
