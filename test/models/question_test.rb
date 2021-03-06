require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  setup do
    @question = Fabricate(:question)
  end

  test 'create' do
    assert_difference 'Question.count' do
      @question = Question.create do |question|
        Fabricate.attributes_for(:question).each do |attr, value|
          question.send "#{attr}=", value
        end
      end
    end
  end

  test 'update' do
    assert_difference 'PaperTrail::Version.count' do
      assert_no_difference 'Question.count' do
        assert @question.update(content: 'Updated')
      end
    end

    assert_equal 'Updated', @question.reload.content
  end

  test 'destroy' do
    assert_difference 'PaperTrail::Version.count' do
      assert_difference('Question.count', -1) { @question.destroy }
    end
  end

  test 'validates blank attributes' do
    @question.content = ''
    @question.question_type = ''

    assert @question.invalid?
    assert_equal 3, @question.errors.size
    assert_equal [error_message_from_model(@question, :content, :blank)],
      @question.errors[:content]
    assert_equal [
      error_message_from_model(@question, :question_type, :blank),
      error_message_from_model(@question, :question_type, :inclusion)
    ].sort, @question.errors[:question_type].sort
  end

  test 'validates length of _long_ attributes' do
    @question.content = 'abcde' * 52

    assert @question.invalid?
    assert_equal 1, @question.errors.count
    assert_equal [
      error_message_from_model(@question, :content, :too_long, count: 255)
    ], @question.errors[:content]
  end

  test 'validates attributes inclusion' do
    @question.question_type = 'wrong'

    assert @question.invalid?
    assert_equal 1, @question.errors.size
    assert_equal [
      error_message_from_model(@question, :question_type, :inclusion)
    ], @question.errors[:question_type]
  end
end
