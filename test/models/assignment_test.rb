require "test_helper"

describe Assignment do
  should belong_to(:store)
  should belong_to(:employee)
end
