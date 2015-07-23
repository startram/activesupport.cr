module ActiveSupport
  # Wrapping a string in this class gives you a prettier way to test
  # for equality. Instead of:
  #
  #   string == "foo"
  #
  # you can call this:
  #
  #   StringInquirer.new(string).foo?
  class StringInquirer
    def initialize(@string : String)
    end

    macro method_missing(name, args, block)
      {% if name.id.ends_with?("?") %}
        @string == {{name.id.stringify[0..-2]}}
      {% else %}
        @string.{{name.id}}({{*args}}) {{block}}
      {% end %}
    end
  end
end
