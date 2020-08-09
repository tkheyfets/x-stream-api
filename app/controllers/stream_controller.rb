class StreamController < ApplicationController
  NUMBERS_COUNT = 100_000
  FLUSH_EVERY = 500

  def index
    # Tell Rack to stream the content
    headers.delete("Content-Length")

    # Don't cache anything from this generated endpoint
    headers["Cache-Control"] ||= "no-cache"

    # Don't buffer when going through proxy servers
    headers["Content-Type"] = "application/x-json-stream"

    headers["Content-Disposition"] = "attachment"
    headers["X-Accel-Buffering"] = "no"

    # Set an Enumerator as the body
    self.response_body = body
    # Set the status to success
    response.status = 200
  end

  private

  def body
    Enumerator.new do |yielder|
      yielder << { chunkSize: FLUSH_EVERY, total: NUMBERS_COUNT }.to_json << "\n"
      bufferArray = []
      NUMBERS_COUNT.times do |i|
        bufferArray.push(random_number_object_lazy(i))
        if i % FLUSH_EVERY == 0 && i != 0
          yielder << bufferArray.to_json << "\n"
          bufferArray.clear
        end 

        if i % 5_000 == 0
          sleep 0.1
        end
      end
      yielder << "\n"
    end  
  end

  def random_number_object_lazy(index)
    random_number = SecureRandom.random_number(100)
    {
      index:  index,
      time:   Time.current.xmlschema(3),
      number: random_number
    }
  end
end
