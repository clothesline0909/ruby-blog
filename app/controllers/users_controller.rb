class UsersController < ApplicationController

    before_action :require_user, only: [:edit, :update, :destroy]
    before_action :set_user, only: [:edit, :update, :show, :destroy]
    before_action :require_access, only: [:edit, :update]
    before_action :require_admin, only: [:destroy]

    def index
        @users = User.paginate(page: params[:page], per_page: 5)
    end

    def show
        @user_articles = @user.articles.paginate(page: params[:page], per_page: 5)
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            session[:user_id] = @user.id
            flash[:success] = "Welcome to the Alpha Blog #{@user.username}."
            redirect_to user_path(@user)
        else
            render :new
        end
    end

    def edit
    end

    def update
        if @user.update(user_params)
            flash[:success] = "Your account was successfully updated."
            redirect_to articles_path
        else 
            redirect_to 'edit'
        end
    end

    def destroy
        @user.destroy
        flash[:success] = "User has been deleted with all created articles."
        redirect_to users_path
    end

    private 
        def user_params
            params.require(:user).permit(:username, :email, :password)
        end

        def set_user
            @user = User.find(params[:id])
        end

        def require_access
            if @user != current_user or !current_user.admin?
                flash[:danger] = "You can only edit your own account."
                redirect_to user_path(current_user)
            end
        end

        def require_admin
            if !current_user.admin?
                flash[:danger] = "You must be admin to perform this action."
                redirect_to users_path
            end
        end
end