# frozen_string_literal: true

require_relative 'initializable'

class Runa::Response
  include Initializable

  STATUS = { completed: 'COMPLETED', success: 'SUCCESS', processing: 'PROCESSING', failed: 'FAILED', error: 'ERROR' }.freeze

  # Field Name Contents
  #
  # status  - The status of the transaction. Usually “SUCCESS” or “ERROR”
  # type    - An error code or type.
  # message - A human readable summary of the error.
  # help    - Additional information that pertains to the error. [optional]

  # global shared body
  attr_accessor :payload, :status, :error_code, :error_string, :error_details

  def is_successful?
    @status&.eql?(STATUS[:completed]) ||  @status&.eql?(STATUS[:success])
  end

  def parse(response = {})
    # TODO: JSON responses, when requested?
    # let's fix that with a simpel catch all
    if response.success? && response['content-type'].eql?('application/json')
      @payload = JSON.parse(response.body)
      @status = STATUS[:completed]
      @error_code = @payload['type']
      @error_string = @payload['message']
      @error_details = @payload['help']
    else
      @payload = JSON.parse(response.body)
      @status = STATUS[:failed]
      @error_code = response.status
      @error_string = response.reason_phrase
      @error_details = response.reason_phrase
    end
  end
end
