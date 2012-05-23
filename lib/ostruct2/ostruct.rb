require 'ostruct2'

class OpenStruct < OpenStruct2
  def __class__
    OpenStruct
  end
end
