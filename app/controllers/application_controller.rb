class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_current_institution, :load_enrollments
  after_filter :add_pjax_headers, if: :pjax_request?
  after_filter -> { expires_now if user_signed_in? }
  
  helper_method :current_institution, :current_enrollments

  rescue_from Exception do |exception|
    begin
      @title = t('errors.title')
      
      if response.redirect_url.blank?
        render template: 'shared/show_error', locals: { error: exception }
      end

      logger.error(([exception, ''] + exception.backtrace).join("\n"))

    # In case the rescue explodes itself =)
    rescue => ex
      logger.error(([ex, ''] + ex.backtrace).join("\n"))
    end
  end

  rescue_from ::ActionController::RoutingError, ::ActiveRecord::RecordNotFound do |exception|
    @title = t('errors.title')

    render template: 'shared/show_404', locals: { error: exception }
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: t('errors.access_denied')
  end

  def user_for_paper_trail
    current_user.try(:id)
  end
  
  def current_institution
    @_current_institution
  end

  def current_enrollments
    @_enrollments
  end

  def not_found
    redirect_to root_url
  end
  
  private
  
  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
  
  def set_current_institution
    @_current_institution ||= Institution.find_by_identification(
      request.subdomains.first
    )
  end

  def load_enrollments
    if current_user && current_institution
      @_enrollments = current_user.enrollments.in_institution(
        current_institution
      ).sorted_by_name.in_current_teach
    end
  end

  def add_pjax_headers
    response.headers['X-PJAX-Searchable'] = 'true' if @searchable
    response.headers['X-PJAX-Controller'] = controller_name
    response.headers['X-PJAX-Action']     = action_name
    response.headers['X-PJAX-Title']      = @title || ''
  end
end
