class Notifier < ActionMailer::Base
  layout 'notifier_mailer'
  helper :application
  default from: "'#{I18n.t('app_name')}' <#{APP_CONFIG['support_email']}>"
  
  def enrollment_status(enrollment)
    # TODO: fix when nested through works =)
    @institution = enrollment.grade.try(:institution)
    @enrollment = enrollment
    @users = [enrollment.user] + enrollment.user.relatives.to_a
    
    mail(
      subject: t(
        'notifier.enrollment_status.subject',
        user: @enrollment.user,
        course: @enrollment.course
      ),
      to: @enrollment.user.email,
      cc: @enrollment.user.relatives.map(&:email)
    )
  end

  def new_forum(forum, institution)
    @institution = institution
    @forum = forum
    users = @forum.users

    mail(
      subject: t('notifier.new_forum.subject', forum: @forum),
      bcc: users.map(&:email)
    )
  end

  def new_comment(comment, institution)
    @institution = institution
    @comment = comment
    @commentable = @comment.commentable
    users = @commentable.users

    mail(
      subject: t(
        'notifier.new_comment.subject',
        commentable: @commentable,
        commentable_name: @commentable.class.model_name.human
      ),
      bcc: users.map(&:email)
    )
  end

  def new_enrollment(enrollment)
    # TODO: fix when nested through works =)
    @institution = enrollment.grade.try(:institution)
    @enrollment = enrollment
    @users = [enrollment.user] + enrollment.user.relatives.to_a

    mail(
      subject: t(
        'notifier.new_enrollment.subject',
        user: @enrollment.user.name,
        course: @enrollment.course
      ),
      to: enrollment.user.email,
      cc: enrollment.user.relatives.map(&:email)
    )
  end
end
