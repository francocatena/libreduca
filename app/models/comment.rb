class Comment < ActiveRecord::Base
  has_paper_trail ignore: [
    :votes_positives_count, :votes_negatives_count, :lock_version, 
    :updated_at
  ]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :comment, :lock_version

  # Write once attributes
  attr_readonly :user_id

  # Default order
  default_scope order("#{table_name}.created_at ASC")
  scope :reverse_order, order("#{table_name}.created_at DESC")

  # Validations
  validates :comment, :user_id, :commentable_id, presence: true
  
  # Relations
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true
  has_many :votes, as: :votable, dependent: :destroy

  def to_s
    self.comment
  end

  def anchor
    "comment-#{self.id}"
  end

  def anchor_vote
    "comment-vote-#{self.id}"
  end

  def voted_by(user)
    self.votes.where(user_id: user.id).first
  end
end
