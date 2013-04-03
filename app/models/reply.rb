class Reply < ActiveRecord::Base
  include Replies::ValidReply

  has_paper_trail

  # Setup accessible (or protected) attributes for your model
  attr_accessible :answer_id, :question_id, :response

  # Not modifiable attributes
  attr_readonly :user_id

  # Callbacks
  before_destroy -> { false }

  # Validations
  validates :question, :user, presence: true
  validates_each :question do |record, attr, value|
    if value && record.user && record.new_record?
      record.errors.add attr, :taken if value.has_been_answered_by? record.user
    end
  end

  # Relations
  belongs_to :answer
  belongs_to :question
  belongs_to :user
  has_one :survey, through: :question
  has_one :content, through: :survey

  def self.of_questions(*args)
    joins(:question).where("#{Question.table_name}.id" => args)
  end
end
