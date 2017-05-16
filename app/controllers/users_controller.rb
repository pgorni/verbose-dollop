class UsersController < ApplicationController
    
    # GET /users
    def index
        @users = User.all
        render json: @users, status: :ok
    end

    # GET /user/:id
    def show
        #render json: User.find(params[:id]), status: :ok

        if User.exists?(params[:id])
            render json: User.find(params[:id]), status: :ok
        else
            render json: {error: "User not found."}, status: :not_found
        end

    end

    def create
        @new_user = User.new(params.require(:user).permit(:name, :surname, :hobby))
        auth_data = params.require(:auth).permit(:uuid, :secret_token)
        @error = {}

        if auth(auth_data)
            # check user
            if @new_user.valid?
                @new_user.save
                render json: {result: "User created.", user: @new_user.as_json}, status: :created
            else
                render json: {error: "User invalid.", messages: @new_user.errors.messages}, status: 422
            end
        else
            # this will be an error of some kind
            render json: @error, status: :forbidden
        end
        
        

    end

    private

    def auth(auth_data)

        # this will serve as a shorthand to checking completeness
        auth_data_db_entry = AuthToken.new(auth_data)

        if auth_data_db_entry.valid? # in terms of completeness
            # we can look up if there's such an entry in the DB
            unless AuthToken.find_by(auth_data).nil?
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

end
