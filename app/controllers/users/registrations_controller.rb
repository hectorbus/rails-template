class Users::RegistrationsController < Devise::RegistrationsController
  layout 'application', except: [:new, :create]
  layout 'out_system', only: [:new, :create]
  add_breadcrumb proc { I18n.t('breadcrumbs.users') }, :user_registrations_path

  before_action :set_user, only: [:show, :edit_user, :update_user, :destroy, :change_password, :save_password, :get_user_image]
  before_action :set_current_user, only: [:edit, :update]
  skip_before_action :is_authorized, only: [:edit, :update, :new, :create]

  # before_filter :configure_sign_up_params, only: [:create]
  # before_filter :configure_account_update_params, only: [:update]

  # GET /users
  def index
    @search_users = policy_scope(User).ransack(params[:q])
    @users = @search_users.result.paginate(page: params[:page], per_page: 20)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    add_breadcrumb @user.full_name, :user_path
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /resource/sign_up
  def new
    @user = User.new
  end

  # GET /users/new_user
  def new_user
    add_breadcrumb t('helpers.new'), :new_user_path
    @user = User.new
  end

  # GET /resource/edit
  def edit
    add_breadcrumb current_user.full_name, :edit_profile_path
    super
  end

  # GET /roles/1/edit
  def edit_user
    add_breadcrumb t('helpers.edit'), :edit_user_path
  end

  # POST /resource
  # def create
  # super
  # end

  # POST /users
  # POST /users.json
  def create_user
    @user = User.new(sign_up_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to user_registrations_path, notice: t('notifications_masc.success.resource.created',
                                                                     resource: t('users.registrations.new_user.resource')) }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new_user }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resource
  def update
    super
  end

  def get_user_image
    if params[:user]
      respond_to do |format|
        if @user.update_attributes(update_avatar)
          format.html { redirect_to edit_profile_path, notice: t('notifications_fem.success.resource.updated',
                                                                 resource: t('users.registrations.edit.profile_image')) }
        end
      end
    else
      redirect_to edit_profile_path
      flash[:notice] = t('users.registrations.edit.need_image')
    end
  end

  # PATCH/PUT /roles/1
  # PATCH/PUT /roles/1.json
  def update_user
    prev_unconfirmed_email = @user.unconfirmed_email if @user.respond_to?(:unconfirmed_email)

    if @user.update(account_update_params)
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      set_flash_message :notice, :updated
      flash.now[:notice] = t('notifications_masc.success.resource.destroyed',
                             resource: t('users.registrations.new_user.resource'))
      redirect_to user_registrations_path
    else
      render 'edit_user'
    end
  end

  # DELETE /resource
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to user_registrations_url }
      format.json { head :no_content }
    end
  end

  # GET /users/change_password
  def change_password
    add_breadcrumb t('breadcrumbs.change_password', username: @user.username), :change_password_path
  end

  # Saves a user's password
  def save_password
    flag = true if @user.eql? current_user
    user = @user

    respond_to do |format|
      if @user.update(account_update_params)
        # Sign in the user by passing validation in case their password changed
        sign_in user, bypass: true if flag
        format.html { redirect_to user_registrations_path,
                                  notice: t('notifications_fem.success.resource.updated',
                                            resource: t('helpers.password')) }
        format.json { head :no_content }
      else
        format.html { render :change_password }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_current_user
    @user = current_user
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username, :first_name, :last_name,
                                 :maiden_name, :role_id)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username, :first_name, :last_name,
                                 :maiden_name, :role_id)
  end

  def profile_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :avatar)
  end

  def update_avatar
    params.require(:user).permit(:avatar)
  end
end
