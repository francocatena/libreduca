module Questions::Type
  extend ActiveSupport::Concern

  included do
    TYPES = ['multiple_choice', 'text', 'list']

    validates :question_type, inclusion: { in: TYPES }, allow_nil: false,
      allow_blank: false

    TYPES.each do |type|
      define_method("#{type}?") { self.question_type == type }
    end
  end
end
