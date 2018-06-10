module Punkt
  class SentenceTokenizer < Base
    def initialize(train_text_or_parameters,
                   language_vars = Punkt::LanguageVars.new,
                   token_class   = Punkt::Token)

      super(language_vars, token_class)

      @trainer = nil

      if train_text_or_parameters.kind_of?(Symbol)
        @parameters = Parameters.load_language(train_text_or_parameters)
      elsif train_text_or_parameters.kind_of?(String)
        @parameters = train(train_text_or_parameters)
      elsif train_text_or_parameters.kind_of?(Punkt::Parameters)
        @parameters = train_text_or_parameters
      else
        raise "You need to pass trainer parameters or a text to train."
      end
    end

    def sentences_from_text(text, options = {})
      sentences = split_in_sentences(text)
      sentences = realign_boundaries(text, sentences) if options[:realign_boundaries]
      sentences = self.class.send(options[:output], text, sentences) if options[:output]

      return sentences
    end
    alias_method :tokenize, :sentences_from_text

    def sentences_from_tokens(tokens)
      tokens = annotate_tokens(tokens.map { |t| @token_class.new(t) })

      sentences = []
      sentence = []
      tokens.each do |t|
        sentence << t.token
        if t.sentence_break
          sentences << sentence
          sentence = []
        end
      end
      sentences << sentence unless sentence.empty?

      return sentences
    end

    class << self
      def sentences_text(text, sentences_indexes)
        sentences_indexes.map { |index| text[index[0]..index[1]] }
      end

      def tokenized_sentences(text, sentences_indexes)
        tokenizer = Punkt::Base.new()
        self.sentences_text(text, sentences_indexes).map { |sentence| tokenizer.tokenize_words(sentence, :output => :string) }
      end
    end

  private

    def train(train_text)
      @trainer = Punkt::Trainer.new(@language_vars, @token_class) unless @trainer
      @trainer.train(train_text)
      @parameters = @trainer.parameters
    end

    def split_in_sentences(text)
      result = []
      last_break = 0
      current_sentence_start = 0
      while match = @language_vars.re_period_context.match(text, last_break)
        context = match[0] + match[:after_tok]
        if text_contains_sentence_break?(context)
          result << [current_sentence_start, (match.end(0)-1)]
          match[:next_tok] ? current_sentence_start = match.begin(:next_tok) : current_sentence_start = match.end(0)
        end
        if match[:next_tok]
          last_break = match.begin(:next_tok)
        else
          last_break = match.end(0)
        end
      end
      result << [current_sentence_start, (text.size-1)]
    end

    def text_contains_sentence_break?(text)
      found = false
      annotate_tokens(tokenize_words(text)).each do |token|
        return true if found
        found = true if token.sentence_break
      end
      return false
    end

    def annotate_tokens(tokens)
      tokens = annotate_first_pass(tokens)
      tokens = annotate_second_pass(tokens)
      return tokens
    end

    def annotate_second_pass(tokens)
      pair_each(tokens) do |tok1, tok2|
        next unless tok2
        next unless tok1.ends_with_period?

        token            = tok1.token
        type             = tok1.type_without_period
        next_token       = tok2.token
        next_type        = tok2.type_without_sentence_period
        token_is_initial = tok1.is_initial?

        if @parameters.collocations.include?([type, next_type])
          tok1.sentence_break = false
          tok1.abbr           = true
          next
        end

        if (tok1.abbr || tok1.ellipsis) && !token_is_initial
          is_sentence_starter = orthographic_heuristic(tok2)
          if is_sentence_starter == true
            tok1.sentence_break = true
            next
          end

          if tok2.first_upper? && @parameters.sentence_starters.include?(next_type)
            tok1.sentence_break = true
            next
          end
        end

        if token_is_initial || type == "##number##"
          is_sentence_starter = orthographic_heuristic(tok2)
          if is_sentence_starter == false
            tok1.sentence_break = false
            tok1.abbr           = true
            next
          end

          if is_sentence_starter == :unknown && token_is_initial &&
             tok2.first_upper? && !(@parameters.orthographic_context[next_type] & Punkt::ORTHO_LC != 0)
             tok1.sentence_break = false
             tok1.abbr           = true
          end
        end
      end
      return tokens
    end

    def orthographic_heuristic(aug_token)
      return false if [';', ',', ':', '.', '!', '?'].include?(aug_token.token)

      orthographic_context = @parameters.orthographic_context[aug_token.type_without_sentence_period]
      return true if aug_token.first_upper? && (orthographic_context & Punkt::ORTHO_LC != 0) && !(orthographic_context & Punkt::ORTHO_MID_UC != 0)
      return false if aug_token.first_lower? && ((orthographic_context & Punkt::ORTHO_UC != 0) || !(orthographic_context & Punkt::ORTHO_BEG_LC != 0))
      return :unknown
    end

    def realign_boundaries(text, sentences)
      result = []
      realign = 0
      pair_each(sentences) do |i1, i2|
        s1 = text[i1[0]..i1[1]]
        s2 = i2 ? text[i2[0]..i2[1]] : nil
        #s1 = s1[realign..(s1.size-1)]
        unless s2
          result << [i1[0]+realign, i1[1]] if s1
          next
        end
        if match = @language_vars.re_boundary_realignment.match(s2)
          result << [i1[0]+realign, i1[1]+match[0].strip.size] #s1 + match[0].strip()
          realign = match.end(0)
        else
          result << [i1[0]+realign, i1[1]] if s1
          realign = 0
        end
      end
      return result
    end
  end
end
