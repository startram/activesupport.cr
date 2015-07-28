class String
  # Truncates a given +text+ after a given <tt>length</tt> if +text+ is longer than <tt>length</tt>:
  #
  #   "Once upon a time in a world far far away".truncate(27)
  #   # => "Once upon a time in a wo..."
  #
  # Pass a string or regexp <tt>:separator</tt> to truncate +text+ at a natural break:
  #
  #   "Once upon a time in a world far far away".truncate(27, separator: " ")
  #   # => "Once upon a time in a..."
  #
  #   "Once upon a time in a world far far away".truncate(27, separator: /\s/)
  #   # => "Once upon a time in a..."
  #
  # The last characters will be replaced with the <tt>:omission</tt> string (defaults to "...")
  # for a total length not exceeding <tt>length</tt>:
  #
  #   "And they found that many people were sleeping better.".truncate(25, omission: "... (continued)")
  #   # => "And they f... (continued)"
  def truncate(truncate_at, omission = "...", separator = nil)
    return self unless length > truncate_at

    length_with_room_for_omission = truncate_at - omission.length
    stop = \
      if separator
        rindex(separator, length_with_room_for_omission) || length_with_room_for_omission
      else
        length_with_room_for_omission
      end

    "#{self[0, stop]}#{omission}"
  end

  # Alters the string by removing all occurrences of the patterns.
  #   str = "foo bar test"
  #   str.remove(" test")                 # => "foo bar"
  #   str                                  # => "foo bar"
  def remove(*patterns)
    patterns.inject(self) do |string, pattern|
      string.gsub pattern, ""
    end
  end
end
