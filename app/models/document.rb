class Document < ActiveRecord::Base
  has_paper_trail

  mount_uploader :file, FileUploader

  # Callbacks
  before_save :update_file_attributes

  # Default order
  default_scope -> { order("#{table_name}.created_at ASC") }

  # Validations
  validates :name, :file, presence: true
  validates :name, length: { maximum: 255 }, allow_nil: true, allow_blank: true

  # Relations
  belongs_to :owner, polymorphic: true

  def to_s
    self.name
  end

  def institution
    self.owner.try(:institution)
  end

  private

  def update_file_attributes
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size

      if self.content_type.blank?
        ext = file.file.extension || File.extname(file.file.original_filename)[1..-1]

        self.content_type = Mime::Type.lookup_by_extension(ext.to_s.downcase).to_s
        self.content_type ||= 'application/octet-stream'
      end
    end
  end
end
