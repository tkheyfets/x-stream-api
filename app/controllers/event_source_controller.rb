class EventSourceController < ApplicationController
  include ActionController::Live

  NUMBERS_COUNT = 100_000
  FLUSH_EVERY = 500

  def index
    headers["Content-Type"] = "text/event-stream"
    unique = (Time.current.to_f * 1_000).to_i
    sse = SSE.new(response.stream, retry: 300)
    sse.write({ chunkSize: FLUSH_EVERY, total: NUMBERS_COUNT }, event: 'header', id: unique )
    bufferArray = []
    unique += 1
    NUMBERS_COUNT.times do |i|
        bufferArray.push(random_number_object_lazy(i))
        if i % FLUSH_EVERY == 0 && i != 0
          sse.write(bufferArray, event: 'data', id: unique)	
          bufferArray.clear
          unique += 1
        end 

        if i % 5_000 == 0
          sleep 0.1
        end
    end
    unique += 1
    sse.write(nil, event: 'end', id: unique )
  ensure	
    sse.close
  end

  private

  def random_number_object_lazy(index)
    random_number = SecureRandom.random_number(100)
    {	
      index:  index,
      time:   Time.current.xmlschema(3),
      number: random_number
    }    
  end
end
