require "../inflections"

module ActiveSupport
  module Inflector
    extend self

    # Converts strings to UpperCamelCase.
    # If the +uppercase_first_letter+ parameter is set to false, then produces
    # lowerCamelCase.
    #
    # Also converts "/" to "::" which is useful for converting
    # paths to namespaces.
    #
    #   camelize("active_model")                # => "ActiveModel"
    #   camelize("active_model", false)         # => "activeModel"
    #   camelize("active_model/errors")         # => "ActiveModel::Errors"
    #   camelize("active_model/errors", false)  # => "activeModel::Errors"
    #
    # As a rule of thumb you can think of +camelize+ as the inverse of
    # #underscore, though there are cases where that does not hold:
    #
    #   camelize(underscore("SSLError"))        # => "SslError"
    def camelize(term, uppercase_first_letter = true)
      string = term.to_s
      if uppercase_first_letter
        string = string.gsub(/^[a-z\d]*/) { |s| inflections.acronyms[s]? || s.capitalize }
      else
        string = string.gsub(/^(?:#{inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) { |s| s.downcase }
      end
      string
        .gsub(/(?:_|(\/))([a-z\d]*)/i) { |s, m| "#{m[1]?}#{inflections.acronyms[m[2]]? || m[2].capitalize}" }
        .gsub("/", "::")
    end

    # Makes an underscored, lowercase form from the expression in the string.
    #
    # Changes "::" to "/" to convert namespaces to paths.
    #
    #   underscore("ActiveModel")         # => "active_model"
    #   underscore("ActiveModel::Errors") # => "active_model/errors"
    #
    # As a rule of thumb you can think of +underscore+ as the inverse of
    # #camelize, though there are cases where that does not hold:
    #
    #   camelize(underscore("SSLError"))  # => "SslError"
    def underscore(camel_cased_word)
      return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/

      camel_cased_word
        .to_s
        .gsub("::", "/")
        #.gsub(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { |s, matches| "#{matches[1] && "_"}#{matches[2].downcase}" }
        .gsub(/([A-Z\d]+)([A-Z][a-z])/) { |s, matches| "#{matches[1]}_#{matches[2]}"}
        .gsub(/([a-z\d])([A-Z])/) { |s, matches| "#{matches[1]}_#{matches[2]}"}
        .tr("-", "_")
        .downcase
    end

    # Tweaks an attribute name for display to end users.
    #
    # Specifically, performs these transformations:
    #
    # * Applies human inflection rules to the argument.
    # * Deletes leading underscores, if any.
    # * Removes a "_id" suffix if present.
    # * Replaces underscores with spaces, if any.
    # * Downcases all words except acronyms.
    # * Capitalizes the first word.
    #
    # The capitalization of the first word can be turned off by setting the
    # +:capitalize+ option to false (default is true).
    #
    #   humanize("employee_salary")              # => "Employee salary"
    #   humanize("author_id")                    # => "Author"
    #   humanize("author_id", capitalize: false) # => "author"
    #   humanize("_id")                          # => "Id"
    #
    # If "SSL" was defined to be an acronym:
    #
    #   humanize("ssl_error") # => "SSL error"
    #
    def humanize(lower_case_and_underscored_word, options = {} of Symbol => Bool)
      result = lower_case_and_underscored_word.to_s

      inflections.humans.each do |rule_and_replacement|
        rule, replacement = rule_and_replacement
        if result[rule]?
          result = result.gsub(rule, replacement)
          break
        end
      end

      result = result.gsub(/\A_+/, "").gsub(/_id\z/, "").tr("_", " ")

      result = result.gsub(/([a-z\d]*)/i) do |match|
        inflections.acronyms.fetch(match, match.downcase)
      end

      if options.fetch(:capitalize, true)
        result = result.gsub(/\A\w/) { |match| match.upcase }
      end

      result
    end

    # Replaces underscores with dashes in the string.
    #
    #   dasherize("puni_puni") # => "puni-puni"
    def dasherize(underscored_word)
      underscored_word.tr("_", "-")
    end

    # Applies inflection rules for +singularize+ and +pluralize+.
    #
    #  apply_inflections("post", inflections.plurals)    # => "posts"
    #  apply_inflections("posts", inflections.singulars) # => "post"
    def apply_inflections(word, rules)
      result = word.to_s.dup

      if word.empty? || inflections.uncountables.include?(result.downcase[/\b\w+\Z/])
        result
      else
        rules.each { |rule, replacement| break if result.sub!(rule, replacement) }
        result
      end
    end
  end
end
