class ToDotsies

  #
  # > Summary
  # Converts html files into a format like this:
  # http://dotsies.org/stories/the-runaway-couple.html.
  #
  # Reads in an html file (presumably a story with paragraphs in
  # <p> tags), and outputs an html file.
  #
  # > Dependencies
  # This file currently has dependencies on Ruby 1.9.2.
  #
  # > Known problems
  # What about existing <b> and <u> tags in input files?...
  # - Change them to <em> and some other tags
  #   - And make style to make <em> be just italic, etc.
  #

  def self.gradually_convert txt

    #
    # Read in txt, and split into chunks (words, whitespace, and html tags)
    #

    # Make first paragraph bigger
    txt.sub! "<p>", "<p style='font-size: 46px; line-height:70px;'>"

    # Ol << "txt:\n#{txt}"

    l = []
    txt.scan(/<.+?>|[a-z]+|&[#a-z0-9]+;|\s+|.+?|/i) {|m| l << m }   # Split into words and tags

    max_underlines = l.length / 700   # Add 
    # Ol << "max_underlines: #{max_underlines.inspect}"

    future = "eaioztnshqrdlxcujmwfgypbvk"   # Dotsiefy chars in this order
    underline = {}   # Chars that are underlined (<u> tags), with the count of occurences as the hash value
    blocks = ""   # Chars that are in Dotsies (<b> tags)

    total = l.length.to_f

    word_tally = 0

    #
    # Go through each chunks, ignoring tags and space
    #

    l.each_with_index do |word, i|

      #
      # If we got far enough, underline another letter
      #

      last_fraction_used = (27 - (future.length + 1)) / 35.0
      fraction_used = (27 - future.length) / 35.0
      # Ol << "fraction_used: #{fraction_used.inspect}"
      fraction_through = i / total
      # Ol << "fraction_through: #{fraction_through.inspect}"

      # If we just passed boundary
      if last_fraction_used < fraction_through && fraction_through <= fraction_used
        # Ol << "passed boundary!"
        underline[future.slice!(/^./)] = 0
      end

      next if word !~ /^[a-z]/i   # Ignore if tag or space

      word_tally += 1

      #
      # Go through each letter
      #

      letters = word.split ''
      # Ol << "letters: #{letters.inspect}"
      letters.each do |letter|

        #
        # Handle future and block letters
        #

        # Ol << "letter: #{letter.inspect}"
        letter_downcase = letter.downcase
        next if future.index(letter_downcase)   # Skip, if in future
        next letter.replace("<b>#{letter}</b>") if blocks.index(letter_downcase)   # Make <b> if in blocks

        #
        # It's an underline letter, so increment count, and move to blocks if it exceeded count
        #

        # Ol << "underline: #{underline.inspect}"
        # Ol << "letter_downcase: #{letter_downcase.inspect}"
        # Ol << "underline[letter_downcase]: #{underline[letter_downcase].inspect}"

        next if "etaoinshr".index(letter_downcase) && word_tally % 2 != 0   # Only do every other word, if a common one

        underline[letter_downcase] += 1
        if underline[letter_downcase] >= max_underlines   # If exceeded max number of underlines for the letter
          underline.delete letter_downcase
          blocks << letter_downcase
        end

        letter.replace "<u>#{letter}</u>"
        # Ol << "underline[letter_downcase]: #{underline[letter_downcase].inspect}"

      end

      word.replace letters.join('')

    end

    # Ol << "unfinished underline: #{underline.inspect}"
    # Ol << "unfinished future: #{future.inspect}"

    l.join ''
  end

end


inputfilename = ARGV[0]

content = File.read inputfilename
content = ToDotsies.gradually_convert content
print %`
      <link href="http://dotsies.org/dotsies.css" rel="stylesheet" type="text/css">
      <style type="text/css">
        body {
          font-size: 42px;
          font-family: Dotsies Training Wheels;
          color: #333;
          cursor: default;
          margin: 140px 17%;
        }
        p {
          margin: 0 0 40px;
          line-height: 64px;
        }
        u {
          font-family: Dotsies Wide;
          text-decoration: none;
          border-bottom: solid #7e7 5px;
        }
        b {
          font-family: Dotsies Wide;
          font-weight: normal;
        }
        u:hover {
          font-family: Dotsies Training Wheels;
        }
        h1, h2, h3, h4, h5 {
          font-weight: normal;
          text-align: center;
        }
      </style>

      #{content}
    `