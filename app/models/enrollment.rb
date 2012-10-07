class Enrollment < ActiveRecord::Base
  has_paper_trail
  
  # Scopes
  scope :sorted_by_name, joins(:course).order("#{Course.table_name}.name ASC")
  scope :only_students, where(job: 'student')
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :teach_id, :user_id, :job, :auto_user_name, :lock_version
  
  attr_accessor :auto_user_name
  
  # Callbacks
  before_validation :set_job, on: :create
  
  # Validations
  validates :job, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :teach_id }, allow_blank: true,
    allow_nil: true
  validates :job, length: { maximum: 255 }, allow_nil: true, allow_blank: true
  validates :job, inclusion: { in: Job::TYPES }, allow_nil: true,
    allow_blank: true
  
  # Relations
  belongs_to :user
  belongs_to :teach
  has_one :course, through: :teach
  has_one :grade, through: :course
  has_one :institution, through: :grade
  
  def set_job
    if self.user && self.teach
      institution = self.institution || self.teach.institution || self.teach.grade.institution
      
      self.job = self.user.jobs.in_institution(institution).first.try(:job)
    end
  end
  
  def score_average
    self.scores.weighted_average
  end
  
  def scores
    self.teach.scores.of_user(self.user)
  end
  
  def send_email_summary
    Notifier.delay.enrollment_status(self)
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^is_(\w+)\?$/
      self.job == $1
    else
      super
    end
  end
  
  def self.for_user(user)
    where("#{table_name}.user_id = ?", user.id)
  end
  
  def self.in_institution(institution)
    joins(:institution).where(
      "#{Institution.table_name}.id = ?", institution.id
    )
  end
  
  def self.in_current_teach
    joins(:teach).where(
      [
        "#{Teach.table_name}.start <= :today",
        "#{Teach.table_name}.finish >= :today"
      ].join(' AND '),
      today: Date.today
    )
  end
end
