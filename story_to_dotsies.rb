class StoryToDotsies

  #
  # > Summary
  # Converts html files into a format linke this:
  # http://dotsies.org/stories/the-runaway-couple.html.
  #
  # Reads in an html file (presumably a story with paragraphs in
  # <p> tags), and outputs an html file.
  #
  # > Dependencies
  # This file currently has dependencies on Xiki.  At the beginning
  # it calles a Xiki function to get the filename.  At the end it
  # tells Xiki to send the html to the browser so we can see it (in
  # addition to the script writing to a file).
  #
  # > Filenames
  # Normally the input file passed will end in "--in.html".  If it
  # doesn't, the script looks for a file that ends that way.  If it
  # finds it, it uses it.  If it doesn't find it, it assumes the
  # file passed was an input file, and so renames it to end that way
  # before moving on.
  #
  # > Known problems
  # What about existing <b> and <u> tags in input files?...
  # - Change them to <em> and some other tags
  #   - And make style to make <em> be just italic, etc.
  #

  def self.menu *args

    #
    # Get name of input file (or output file) from Xiki.
    #

    path = Tree.dir :file=>1

    # Handle it when "--in.html" file wasn't passed in
    path_in = path =~ /--in\./ ? path : path.sub(/(.+)\./, "\\1--in.")
    path_out = path.sub("--in.", ".")
    File.rename path, path_in if ! File.exists? path_in   # If no "--in" version yet, assume this is it

    txt = File.read path_in

    #
    # Read in file, and split into chunks (words, whitespace, and html tags)
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

    txt = l.join ''
    txt = self.template txt   # Add surrounding html styles, etc.

    File.open(path_out, "w") { |f| f << txt }

    Browser.url "file://#{path_out}"

    "| done!"

  end


  def self.template txt
    %`
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

      <h1 style="font-size:130px;">hi there!</h1>
      <h1>can you read this?</h1>

      <center style="font-family:arial; font-size:15px; margin:0px 20%">
        Read this story to gradually learn to read using
        <a href="http://dotsies.org">dots instead of
        letters!</a>
        Move your mouse over the green
        underlines
        when
        you need a hint.
        If you get to
        the
        end,
        you'll be reading only dots!
      </center>

      #{txt}
    `
  end

end
