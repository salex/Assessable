module Assessable
  module ApplicationHelper
    def status_options(status)
      if status.nil?
        status = ""
      end
      types = [""] + Assessable.config[:assessment_status_options]
      result = options_for_select(types,status.capitalize)
      return result.html_safe
    end

    def answer_type_options(answer_type)
      if answer_type.nil?
        answer_type = ""
      end
      types = %W( #{""} Radio Checkbox Select Select-multiple Text Textarea)
      result = options_for_select(types,answer_type.capitalize)
      return result.html_safe
    end
    
    def score_method_options(score_method)
      if score_method.nil?
        score_method = ""
      end
      types = %W( Value Sum Max None TextContains TextNumeric)
      result = options_for_select(types,score_method)
      return result.html_safe
    end
    
    def display_type_options(display_type,empty=false)
      if display_type.nil?
        display_type = ""
      end
      types = empty ? %W( #{""} List Inline None) : %W( List Inline None)
      result = options_for_select(types,display_type.capitalize)
      return result.html_safe
    end
    
    
    def truncateText(text,length = 40, where = "end")
      if text.nil?
        return text
      end
      text_length = text.length
      if text_length <= length
        return text
      end
      result = ""
      if where.downcase == "end"
        result = ( text.first(length)+"&hellip;")
      elsif where.downcase == "begin"
        result = ( text.last(length)+"&hellip;")
      else
        result = (text.first(length / 2)+"&hellip;"+ text.last(length / 2))
      end
      return result.html_safe
    end
    
  end
end
