module Punkt
  class Token
    attr_accessor :token, :type, :period_final
    attr_accessor :paragraph_start, :line_start
    attr_accessor :sentence_break, :abbr, :ellipsis

    def initialize(token, options = {})
      valid_options = [:paragraph_start, :line_start, :sentence_break, :abbr, :ellipsis]
      @token        = token
      @type         = token.downcase.gsub(/^-?[\.,]?\d[\d,\.-]*\.?$/, '##number##') # numeric
      @period_final = token.end_with?('.')

      valid_options.each do |item|
        self.instance_variable_set(("@"+item.to_s).to_sym, nil)
      end
      options.each do |key, value|
        self.instance_variable_set(("@"+key.to_s).to_sym, value) if valid_options.include?(key)
      end
    end

    def type_without_period
      @type.size > 1 && @type.end_with?('.') ? @type.chop : @type
    end

    def type_without_sentence_period
      @sentence_break ? type_without_period : @type
    end

    def first_upper?
      @token[0] =~ /[[:upper:]]/
    end

    def first_lower?
      @token[0] =~ /[[:lower:]]/
    end

    def first_case
      return :lower if first_lower?
      return :upper if first_upper?
      return :none
    end

    def ends_with_period?
      @period_final
    end

    def is_ellipsis?
      !(@token =~ /^\.\.+$/).nil?
    end

    def is_number?
      @type.start_with?("##number##")
    end

    def is_initial?
      !(@token =~ /^[^\W\d]\.$/).nil?
    end

    def is_alpha?
      !(@token =~ /^[^\W\d]+$/).nil?
    end

    def is_non_punctuation?
      !(@type =~ /[^\W\d]/).nil?
    end

    def to_s
      result = @token
      result += '<A>' if @abbr
      result += '<E>' if @ellipsis
      result += '<S>' if @sentence_break
      result
    end

    def inspect
      "<#{to_s}>"
    end
  end
end
