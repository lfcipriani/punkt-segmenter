require "nlp/probability/frequency_distribution"

module Punkt
  class Trainer < Base
    
    # cut-off value whether a 'token' is an abbreviation
    ABBREV = 0.3 
    
    # allows the disabling of the abbreviation penalty heuristic, which
    # exponentially disadvantages words that are found at times without a
    # final period.
    IGNORE_ABBREV_PENALTY = false

    # upper cut-off for Mikheev's(2002) abbreviation detection algorithm
    ABBREV_BACKOFF = 5

    # minimal log-likelihood value that two tokens need to be considered
    # as a collocation
    COLLOCATION = 7.88

    # minimal log-likelihood value that a token requires to be considered
    # as a frequent sentence starter
    SENT_STARTER = 30

    # this includes as potential collocations all word pairs where the first
    # word ends in a period. It may be useful in corpora where there is a lot
    # of variation that makes abbreviations like Mr difficult to identify.
    INCLUDE_ALL_COLLOCS = true #TODO colocar false
    
    # this includes as potential collocations all word pairs where the first
    # word is an abbreviation. Such collocations override the orthographic
    # heuristic, but not the sentence starter heuristic. This is overridden by
    # INCLUDE_ALL_COLLOCS, and if both are false, only collocations with initials
    # and ordinals are considered.
    INCLUDE_ABBREV_COLLOCS = false

    # this sets a minimum bound on the number of times a bigram needs to
    # appear before it can be considered a collocation, in addition to log
    # likelihood statistics. This is useful when INCLUDE_ALL_COLLOCS is True.
    MIN_COLLOC_FREQ = 1
        
    def initialize(train_text    = nil,
                   language_vars = Punkt::LanguageVars.new, 
                   token_class   = Punkt::Token)
                   
      super(language_vars, token_class)
      
      @type_fdist             = FrequencyDistribution.new
      @collocation_fdist      = FrequencyDistribution.new
      @sentence_starter_fdist = FrequencyDistribution.new
      @period_tokens_count    = 0
      @sentence_break_count   = 0
      @finalized              = false
      
      train(train_text, true) if train_text
    end
    
    def train(text_or_tokens, finalize=true)
      text_or_tokens = tokenize_words(text_or_tokens) if text_or_tokens.kind_of?(String)
      train_tokens(text_or_tokens)
    end
    
  private 
  
    def train_tokens(tokens)
      tokens.each do |token|
        @type_fdist << token.type
        @period_tokens_count += 1 if token.ends_with_period?
      end
      
      unique_types = Set.new(tokens.map { |t| t.type })
      
      reclassify_abbreviation_types(unique_types) do |abbr, score, is_add|
        if score >= ABBREV
          @parameters.abbreviation_types << abbr if is_add
        else
          @parameters.abbreviation_types.delete(abbr) unless is_add
        end
      end
      
      tokens = annotate_first_pass(tokens)

      get_orthography_data(tokens)
      
      tokens.each { |token| @sentence_break_count += 1 if token.sentence_break }

      pair_each(tokens) do |tok1, tok2|         
        next if !tok1.ends_with_period? || !tok2
        
        if is_rare_abbreviation_type?(tok1, tok2)
          @parameters.abbreviation_types << tok1.type_without_period 
        end
        
        if is_potential_sentence_starter?(tok2, tok1)
          @sentence_starter_fdist << tok2.type
        end
        
        if is_potential_collocation?(tok1, tok2)
          @collocation_fdist << [tok1.type_without_period, tok2.type_without_sentence_period]
        end
      end
    end
    
    def reclassify_abbreviation_types(types, &block)
      types.each do |type|
        # if there is punctuation or is a number, continue. This will be processed later
        next if (type =~ /[^\W\d]/).nil? || type == "##number##" 
          
        if type.end_with?(".")
          next if @parameters.abbreviation_types.include?(type)
          type = type.chop
          is_add = true
        else
          next unless @parameters.abbreviation_types.include?(type)
          is_add = false
        end
        
        periods_count = type.count(".") + 1
        non_periods_count = type.size - periods_count + 1
        
        with_periods_count     = @type_fdist[type + "."]
        without_periods_count  = @type_fdist[type]
        
        ll = dunning_log_likelihood(with_periods_count + without_periods_count,
                                    @period_tokens_count, 
                                    with_periods_count,
                                    @type_fdist.N)
        
        f_length  = Math.exp(-non_periods_count)
        f_periods = periods_count
        f_penalty = IGNORE_ABBREV_PENALTY ? 0 : non_periods_count**(-without_periods_count).to_f
        
        score = ll * f_length * f_periods * f_penalty
        
        yield(type, score, is_add)
      end
    end
    
    def dunning_log_likelihood(count_a, count_b, count_ab, n)
      p1 = count_b.to_f / n
      p2 = 0.99

      null_hypo = (count_ab.to_f * Math.log(p1) +
                   (count_a - count_ab) * Math.log(1.0 - p1))
      alt_hypo  = (count_ab.to_f * Math.log(p2) +
                   (count_a - count_ab) * Math.log(1.0 - p2))

      likelihood = null_hypo - alt_hypo

      return (-2.0 * likelihood)
    end
    
    def get_orthography_data(tokens)
      context = :internal
      
      tokens.each do |aug_token|
        context = :initial if aug_token.paragraph_start && context != :unknown
        context = :unknown if aug_token.line_start && context == :internal
        
        type = aug_token.type_without_sentence_period

        flag = Punkt::ORTHO_MAP[[context, aug_token.first_case]] || 0
        @parameters.add_orthographic_context(type, flag) if flag
        
        if aug_token.sentence_break
          context = !(aug_token.is_number? || aug_token.is_initial?) ? :initial : :unknown
        elsif aug_token.ellipsis || aug_token.abbr
          context = :unknown
        else
          context = :internal
        end
      end
    end
    
    def is_rare_abbreviation_type?(current_token, next_token)
      return false if current_token.abbr || !current_token.sentence_break
      
      type = current_token.type_without_sentence_period
      
      count = @type_fdist[type] + @type_fdist[type.chop]
      return false if (@parameters.abbreviation_types.include?(type) || count >= ABBREV_BACKOFF)

      if @language_vars.internal_punctuation.include?(next_token.token[0])
        return true
      elsif
        type2 = next_token.type_without_sentence_period
        type2_orthographic_context = @parameters.orthographic_context[type2]
        return true if (type2_orthographic_context & Punkt::ORTHO_BEG_UC) && (type2_orthographic_context & Punkt::ORTHO_MID_UC)
      end      
    end
    
    def is_potential_sentence_starter?(current_token, previous_token)
      return (previous_token.sentence_break && 
              !(previous_token.is_number? || previous_token.is_initial?) && 
              current_token.is_alpha?)
    end
    
    def is_potential_collocation?(tok1, tok2)
      return (
                (INCLUDE_ALL_COLLOCS || 
                  (INCLUDE_ABBREV_COLLOCS && tok1.abbr) || 
                  (tok1.sentence_break && 
                    (tok1.is_number? || tok2.is_initial?)
                  )
                ) 
                && tok1.is_non_punctuation? 
                && tok2.is_non_punctuation?
             )
    end
  end
end
