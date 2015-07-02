defmodule XtractTest do
  use ExUnit.Case

  def example_xml do
    """
    <book num="Gen">
      <chapter num="1">
        <verse num="1">In the beginning God created the heaven and the earth.</verse>
        <verse num="2">And the earth was without form, and void; and darkness <i>was</i> upon the face of the deep. And the Spirit of God moved upon the face of the waters.</verse>
        <verse num="3">And God said, Let there be light: and there was light.</verse>
      </chapter>
    </book>
    """
  end
  
  test "Xtract.Parser.parse/1 can xtract values" do
    xtracted_data = Xtract.Parser.parse(example_xml)
    book = List.first(xtracted_data)
    assert book[:num] == "Gen"
  end
end

