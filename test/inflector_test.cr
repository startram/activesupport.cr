require "minitest/autorun"
# require "abstract_unit"
require "../src/activesupport/inflector"

require "./inflector_test_cases"
# require "constantize_test_cases"

class InflectorTest < Minitest::Test
   include InflectorTestCases
#   include ConstantizeTestCases

  def setup
    ActiveSupport::Inflector.inflections(:en).clear
    ActiveSupport::Inflector.apply_default_english_inflections
  end

  def test_pluralize_plurals
    assert_equal "plurals", ActiveSupport::Inflector.pluralize("plurals")
    assert_equal "Plurals", ActiveSupport::Inflector.pluralize("Plurals")
  end

  def test_pluralize_empty_string
    assert_equal "", ActiveSupport::Inflector.pluralize("")
  end

  def test_uncountability
    ActiveSupport::Inflector.inflections.uncountable.each do |word|
      assert_equal word, ActiveSupport::Inflector.singularize(word)
      assert_equal word, ActiveSupport::Inflector.pluralize(word)
      assert_equal ActiveSupport::Inflector.pluralize(word), ActiveSupport::Inflector.singularize(word)
    end
  end

  def test_uncountable_word_is_not_greedy
    uncountable_word = "ors"
    countable_word = "sponsor"

    ActiveSupport::Inflector.inflections.uncountable(uncountable_word)

    assert_equal uncountable_word, ActiveSupport::Inflector.singularize(uncountable_word)
    assert_equal uncountable_word, ActiveSupport::Inflector.pluralize(uncountable_word)
    assert_equal ActiveSupport::Inflector.pluralize(uncountable_word), ActiveSupport::Inflector.singularize(uncountable_word)

    assert_equal "sponsor", ActiveSupport::Inflector.singularize(countable_word)
    assert_equal "sponsors", ActiveSupport::Inflector.pluralize(countable_word)
    assert_equal "sponsor", ActiveSupport::Inflector.singularize(ActiveSupport::Inflector.pluralize(countable_word))
  end

  {% for singular, plural in SINGULAR_TO_PLURAL %}
    def test_pluralize_singular_{{singular.id.gsub(/[^A-Za-z]/, "_")}}
      singular = {{singular}}
      plural = {{plural}}

      assert_equal plural, ActiveSupport::Inflector.pluralize(singular)
      assert_equal plural.capitalize, ActiveSupport::Inflector.pluralize(singular.capitalize)
    end

    def test_singularize_plural_{{plural.id.gsub(/[^A-Za-z]/, "_")}}
      singular = {{singular}}
      plural = {{plural}}

      assert_equal singular, ActiveSupport::Inflector.singularize(plural)
      assert_equal singular.capitalize, ActiveSupport::Inflector.singularize(plural.capitalize)
    end

    def test_pluralize_plural_{{plural.id.gsub(/[^A-Za-z]/, "_")}}
      singular = {{singular}}
      plural = {{plural}}

      assert_equal plural, ActiveSupport::Inflector.pluralize(plural)
      assert_equal plural.capitalize, ActiveSupport::Inflector.pluralize(plural.capitalize)
    end

    def test_singularize_singular_{{singular.id.gsub(/[^A-Za-z]/, "_")}}
      singular = {{singular}}
      plural = {{plural}}

      assert_equal singular, ActiveSupport::Inflector.singularize(singular)
      assert_equal singular.capitalize, ActiveSupport::Inflector.singularize(singular.capitalize)
    end
  {% end %}

  def test_overwrite_previous_inflectors
    assert_equal("series", ActiveSupport::Inflector.singularize("series"))
    ActiveSupport::Inflector.inflections.singular "series", "serie"
    assert_equal("serie", ActiveSupport::Inflector.singularize("series"))
  end

  # used define_method for individual tests in ruby
  def test_titleize_mixture_to_title_case
    MIXTURE_TO_TITLE_CASE.each do |before, titleized|
      assert_equal titleized, ActiveSupport::Inflector.titleize(before)
    end
  end

  def test_camelize
    CamelToUnderscore.each do |camel, underscore|
      assert_equal(camel, ActiveSupport::Inflector.camelize(underscore))
    end
  end

  def test_camelize_with_lower_downcases_the_first_letter
    assert_equal("capital", ActiveSupport::Inflector.camelize("Capital", false))
  end

  def test_camelize_with_underscores
    assert_equal("CamelCase", ActiveSupport::Inflector.camelize("Camel_Case"))
  end

  def test_acronyms
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("HTML")
      inflect.acronym("HTTP")
      inflect.acronym("RESTful")
      inflect.acronym("W3C")
      inflect.acronym("PhD")
      inflect.acronym("RoR")
      inflect.acronym("SSL")
    end

    #  camelize             underscore            humanize              titleize
    [
      ["API",               "api",                "API",                "API"],
      ["APIController",     "api_controller",     "API controller",     "API Controller"],
      ["Nokogiri::HTML",    "nokogiri/html",      "Nokogiri/HTML",      "Nokogiri/HTML"],
      ["HTTPAPI",           "http_api",           "HTTP API",           "HTTP API"],
      ["HTTP::Get",         "http/get",           "HTTP/get",           "HTTP/Get"],
      ["SSLError",          "ssl_error",          "SSL error",          "SSL Error"],
      ["RESTful",           "restful",            "RESTful",            "RESTful"],
      ["RESTfulController", "restful_controller", "RESTful controller", "RESTful Controller"],
      ["Nested::RESTful",   "nested/restful",     "Nested/RESTful",     "Nested/RESTful"],
      ["IHeartW3C",         "i_heart_w3c",        "I heart W3C",        "I Heart W3C"],
      ["PhDRequired",       "phd_required",       "PhD required",       "PhD Required"],
      ["IRoRU",             "i_ror_u",            "I RoR u",            "I RoR U"],
      ["RESTfulHTTPAPI",    "restful_http_api",   "RESTful HTTP API",   "RESTful HTTP API"],
      ["HTTP::RESTful",     "http/restful",       "HTTP/RESTful",       "HTTP/RESTful"],
      ["HTTP::RESTfulAPI",  "http/restful_api",   "HTTP/RESTful API",   "HTTP/RESTful API"],
      ["APIRESTful",        "api_restful",        "API RESTful",        "API RESTful"],

      # misdirection
      ["Capistrano",        "capistrano",         "Capistrano",       "Capistrano"],
      ["CapiController",    "capi_controller",    "Capi controller",  "Capi Controller"],
      ["HttpsApis",         "https_apis",         "Https apis",       "Https Apis"],
      ["Html5",             "html5",              "Html5",            "Html5"],
      ["Restfully",         "restfully",          "Restfully",        "Restfully"],
      ["RoRails",           "ro_rails",           "Ro rails",         "Ro Rails"]
    ].each do |camel_under_human_title|
      camel, under, human, title = camel_under_human_title

      assert_equal camel, ActiveSupport::Inflector.camelize(under)
      assert_equal camel, ActiveSupport::Inflector.camelize(camel)
      assert_equal under, ActiveSupport::Inflector.underscore(under)
      assert_equal under, ActiveSupport::Inflector.underscore(camel)
      assert_equal title, ActiveSupport::Inflector.titleize(under)
      assert_equal title, ActiveSupport::Inflector.titleize(camel)
      assert_equal human, ActiveSupport::Inflector.humanize(under)
    end
  end

  def test_acronym_override
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("LegacyApi")
    end

    assert_equal("LegacyApi", ActiveSupport::Inflector.camelize("legacyapi"))
    assert_equal("LegacyAPI", ActiveSupport::Inflector.camelize("legacy_api"))
    assert_equal("SomeLegacyApi", ActiveSupport::Inflector.camelize("some_legacyapi"))
    assert_equal("Nonlegacyapi", ActiveSupport::Inflector.camelize("nonlegacyapi"))
  end

  def test_acronyms_camelize_lower
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("HTML")
    end

    assert_equal("htmlAPI", ActiveSupport::Inflector.camelize("html_api", false))
    assert_equal("htmlAPI", ActiveSupport::Inflector.camelize("htmlAPI", false))
    assert_equal("htmlAPI", ActiveSupport::Inflector.camelize("HTMLAPI", false))
  end

  def test_underscore_acronym_sequence
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("JSON")
      inflect.acronym("HTML")
    end

    assert_equal("json_html_api", ActiveSupport::Inflector.underscore("JSONHTMLAPI"))
  end

  def test_underscore
    CamelToUnderscore.each do |camel, underscore|
      assert_equal underscore, ActiveSupport::Inflector.underscore(camel)
    end

    CamelToUnderscoreWithoutReverse.each do |camel, underscore|
      assert_equal underscore, ActiveSupport::Inflector.underscore(camel)
    end
  end

  def test_camelize_with_module
    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      assert_equal(camel, ActiveSupport::Inflector.camelize(underscore))
    end
  end

  def test_underscore_with_slashes
    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      assert_equal(underscore, ActiveSupport::Inflector.underscore(camel))
    end
  end

  def test_demodulize
    assert_equal "Account", ActiveSupport::Inflector.demodulize("MyApplication::Billing::Account")
    assert_equal "Account", ActiveSupport::Inflector.demodulize("Account")
    assert_equal "Account", ActiveSupport::Inflector.demodulize("::Account")
    assert_equal "", ActiveSupport::Inflector.demodulize("")
  end

  def test_deconstantize
    assert_equal "MyApplication::Billing", ActiveSupport::Inflector.deconstantize("MyApplication::Billing::Account")
    assert_equal "::MyApplication::Billing", ActiveSupport::Inflector.deconstantize("::MyApplication::Billing::Account")

    assert_equal "MyApplication", ActiveSupport::Inflector.deconstantize("MyApplication::Billing")
    assert_equal "::MyApplication", ActiveSupport::Inflector.deconstantize("::MyApplication::Billing")

    assert_equal "", ActiveSupport::Inflector.deconstantize("Account")
    assert_equal "", ActiveSupport::Inflector.deconstantize("::Account")
    assert_equal "", ActiveSupport::Inflector.deconstantize("")
  end

  def test_foreign_key
    ClassNameToForeignKeyWithUnderscore.each do |klass, foreign_key|
      assert_equal(foreign_key, ActiveSupport::Inflector.foreign_key(klass))
    end

    ClassNameToForeignKeyWithoutUnderscore.each do |klass, foreign_key|
      assert_equal(foreign_key, ActiveSupport::Inflector.foreign_key(klass, false))
    end
  end

  def test_tableize
    ClassNameToTableName.each do |class_name, table_name|
      assert_equal(table_name, ActiveSupport::Inflector.tableize(class_name))
    end
  end

  # def test_parameterize
  #   StringToParameterized.each do |some_string, parameterized_string|
  #     assert_equal(parameterized_string, ActiveSupport::Inflector.parameterize(some_string))
  #   end
  # end

#   def test_parameterize_and_normalize
#     jruby_skip "UTF-8 to UTF8-MAC Converter is unavailable"
#     StringToParameterizedAndNormalized.each do |some_string, parameterized_string|
#       assert_equal(parameterized_string, ActiveSupport::Inflector.parameterize(some_string))
#     end
#   end

#   def test_parameterize_with_custom_separator
#     jruby_skip "UTF-8 to UTF8-MAC Converter is unavailable"
#     StringToParameterizeWithUnderscore.each do |some_string, parameterized_string|
#       assert_equal(parameterized_string, ActiveSupport::Inflector.parameterize(some_string, "_"))
#     end
#   end

#   def test_parameterize_with_multi_character_separator
#     jruby_skip "UTF-8 to UTF8-MAC Converter is unavailable"
#     StringToParameterized.each do |some_string, parameterized_string|
#       assert_equal(parameterized_string.gsub("-", "__sep__"), ActiveSupport::Inflector.parameterize(some_string, "__sep__"))
#     end
#   end

  def test_classify
    ClassNameToTableName.each do |class_name, table_name|
      assert_equal(class_name, ActiveSupport::Inflector.classify(table_name))
      assert_equal(class_name, ActiveSupport::Inflector.classify("table_prefix." + table_name))
    end
  end

  def test_classify_with_symbol
    assert_equal "FooBar", ActiveSupport::Inflector.classify(:foo_bars)
  end

  def test_classify_with_leading_schema_name
    assert_equal "FooBar", ActiveSupport::Inflector.classify("schema.foo_bar")
  end

  def test_humanize
    UnderscoreToHuman.each do |underscore, human|
      assert_equal(human, ActiveSupport::Inflector.humanize(underscore))
    end
  end

  def test_humanize_without_capitalize
    UnderscoreToHumanWithoutCapitalize.each do |underscore, human|
      assert_equal human, ActiveSupport::Inflector.humanize(underscore, capitalize: false)
    end
  end

  def test_humanize_by_rule
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.human(/_cnt$/i, "_count")
      inflect.human(/^prefx_/i, "")
    end
    assert_equal("Jargon count", ActiveSupport::Inflector.humanize("jargon_cnt"))
    assert_equal("Request", ActiveSupport::Inflector.humanize("prefx_request"))
  end

  def test_humanize_by_string
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.human("col_rpted_bugs", "Reported bugs")
    end
    assert_equal("Reported bugs", ActiveSupport::Inflector.humanize("col_rpted_bugs"))
    assert_equal("Col rpted bugs", ActiveSupport::Inflector.humanize("COL_rpted_bugs"))
  end

#   def test_constantize
#     run_constantize_tests_on do |string|
#       ActiveSupport::Inflector.constantize(string)
#     end
#   end

#   def test_safe_constantize
#     run_safe_constantize_tests_on do |string|
#       ActiveSupport::Inflector.safe_constantize(string)
#     end
#   end

  def test_ordinal
    OrdinalNumbers.each do |number, ordinalized|
      assert_equal(ordinalized, number + ActiveSupport::Inflector.ordinal(number))
    end
  end

  def test_ordinalize
    OrdinalNumbers.each do |number, ordinalized|
      assert_equal(ordinalized, ActiveSupport::Inflector.ordinalize(number))
    end
  end

  def test_dasherize
    UnderscoresToDashes.each do |underscored, dasherized|
      assert_equal(dasherized, ActiveSupport::Inflector.dasherize(underscored))
    end
  end

  def test_underscore_as_reverse_of_dasherize
    UnderscoresToDashes.each_key do |underscored|
      assert_equal(underscored, ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.dasherize(underscored)))
    end
  end

  def test_underscore_to_lower_camel
    UnderscoreToLowerCamel.each do |underscored, lower_camel|
      assert_equal(lower_camel, ActiveSupport::Inflector.camelize(underscored, false))
    end
  end

  def test_symbol_to_lower_camel
    SymbolToLowerCamel.each do |symbol, lower_camel|
      assert_equal(lower_camel, ActiveSupport::Inflector.camelize(symbol, false))
    end
  end

  {% for inflection_type in ["plurals", "singulars", "uncountables", "humans"] %}
    def test_clear_{{inflection_type.id}}
      ActiveSupport::Inflector.inflections.clear :{{inflection_type.id}}
      assert_empty ActiveSupport::Inflector.inflections.{{inflection_type.id}}, "{{inflection_type.id}} inflections should be empty after clear :{{inflection_type.id}}"
    end
  {% end %}

#   def test_inflector_locality
#     ActiveSupport::Inflector.inflections(:es) do |inflect|
#       inflect.plural(/$/, "s")
#       inflect.plural(/z$/i, "ces")

#       inflect.singular(/s$/, "")
#       inflect.singular(/es$/, "")

#       inflect.irregular("el", "los")
#     end

#     assert_equal("hijos", "hijo".pluralize(:es))
#     assert_equal("luces", "luz".pluralize(:es))
#     assert_equal("luzs", "luz".pluralize)

#     assert_equal("sociedad", "sociedades".singularize(:es))
#     assert_equal("sociedade", "sociedades".singularize)

#     assert_equal("los", "el".pluralize(:es))
#     assert_equal("els", "el".pluralize)

#     ActiveSupport::Inflector.inflections(:es) { |inflect| inflect.clear }

#     assert ActiveSupport::Inflector.inflections(:es).plurals.empty?
#     assert ActiveSupport::Inflector.inflections(:es).singulars.empty?
#     assert !ActiveSupport::Inflector.inflections.plurals.empty?
#     assert !ActiveSupport::Inflector.inflections.singulars.empty?
#   end

  def test_clear_all
    ActiveSupport::Inflector.inflections do |inflect|
      # ensure any data is present
      inflect.plural(/(quiz)$/i, "\1zes")
      inflect.singular(/(database)s$/i, "\1")
      inflect.uncountable("series")
      inflect.human("col_rpted_bugs", "Reported bugs")

      inflect.clear :all

      assert_empty inflect.plurals
      assert_empty inflect.singulars
      assert_empty inflect.uncountables
      assert_empty inflect.humans
    end
  end

  def test_clear_with_default
    ActiveSupport::Inflector.inflections do |inflect|
      # ensure any data is present
      inflect.plural(/(quiz)$/i, "\1zes")
      inflect.singular(/(database)s$/i, "\1")
      inflect.uncountable("series")
      inflect.human("col_rpted_bugs", "Reported bugs")

      inflect.clear

      assert inflect.plurals.empty?
      assert inflect.singulars.empty?
      assert inflect.uncountables.empty?
      assert inflect.humans.empty?
    end
  end

  {% for singular, plural in Irregularities %}
    def test_irregularity_between_{{singular.id}}_and_{{plural.id}}
      ActiveSupport::Inflector.inflections do |inflect|
        singular = {{singular}}
        plural = {{plural}}

        inflect.irregular(singular, plural)
        assert_equal singular, ActiveSupport::Inflector.singularize(plural)
        assert_equal plural, ActiveSupport::Inflector.pluralize(singular)
      end
    end

    def test_pluralize_of_irregularity_{{plural.id}}_should_be_the_same
      ActiveSupport::Inflector.inflections do |inflect|
        singular = {{singular}}
        plural = {{plural}}

        inflect.irregular(singular, plural)
        assert_equal plural, ActiveSupport::Inflector.pluralize(plural)
      end
    end

    def test_singularize_of_irregularity_{{singular.id}}_should_be_the_same
      ActiveSupport::Inflector.inflections do |inflect|
        singular = {{singular}}
        plural = {{plural}}

        inflect.irregular(singular, plural)
        assert_equal singular, ActiveSupport::Inflector.singularize(singular)
      end
    end
  {% end %}

  def test_clear_inflections_with_no_args_and_scope
    [:all, nil].each do |scope|
      ActiveSupport::Inflector.inflections do |inflect|
        # save all the inflections
        singulars, plurals, uncountables = inflect.singulars, inflect.plurals, inflect.uncountables

        # clear all the inflections
        scope.nil? ? inflect.clear : inflect.clear(scope)

        assert inflect.singulars.empty?
        assert inflect.plurals.empty?
        assert inflect.uncountables.empty?

        # restore all the inflections
        singulars.reverse_each { |singular| inflect.singular(*singular) }
        plurals.reverse_each   { |plural|   inflect.plural(*plural) }
        inflect.uncountable(uncountables)

        assert_equal singulars, inflect.singulars
        assert_equal plurals, inflect.plurals
        assert_equal uncountables, inflect.uncountables
      end
    end
  end

  {% for scope in [:plurals, :singulars, :uncountables, :humans, :acronyms] %}
    def test_clear_inflections_with_{{scope.id}}
      # clear the inflections
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.clear({{scope}})
        assert_empty inflect.{{scope.id}}
      end
    end
  {% end %}

  def test_inflections_with_uncountable_words
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.uncountable "HTTP"
    end

    assert_equal "HTTP", ActiveSupport::Inflector.pluralize("HTTP")
  end
end
