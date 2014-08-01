require_relative 'client_proxy'
require_relative 'mobject'

# MarketoAPI operations on Marketo objects (MObject).
class MarketoAPI::MObjects < MarketoAPI::ClientProxy

  # :call-seq:
  #   delete(mobject, mobject, ...) -> status_list
  #
  # Implements
  # {+deleteMObjects+}[http://developers.marketo.com/documentation/soap/deletemobjects/],
  # returning the deletion success status for each object provided.
  #
  # Only works with Opportunity or OpportunityPersonRole MObjects.
  #
  # To delete an Opportunity:
  #
  #   marketo.mobjects.delete MarketoAPI::MObject.opportunity(75)
  def delete(*mobjects)
    if mobjects.empty?
      raise ArgumentError, "must provide one or more MObjects to delete"
    end
    response = call(
      :delete_m_objects,
      mObjectList: transform_param_list(__method__, mobjects)
    )
    extract_mobject_status_list(response)
  end

  # Implements
  # {+listMObjects+}[http://developers.marketo.com/documentation/soap/listmobjects/],
  # returning the type names of the available Marketo objects. The type
  # names can be passed to #describe.
  def list
    extract_from_response(
      call(:list_m_objects, nil),
      :objects
    )
  end

  # Implements
  # {+describeMObject+}[http://developers.marketo.com/documentation/soap/describemobject/],
  # returning the description of the Marketo object.
  def describe(name)
    unless MarketoAPI::MObject::DESCRIBE_TYPES.include?(name.to_sym)
      raise ArgumentError, "invalid type #{name} to describe"
    end

    extract_from_response(
      call(:describe_m_object, objectName: name),
      :metadata
    )
  end

  # Implements
  # {+getMObjects+}[http://developers.marketo.com/documentation/soap/getmobjects/],
  # returning one or more Marketo objects, up to 100 in a page. It also
  # returns the current current stream position to continue working with the
  # pages on subsequent calls to #get.
  #
  # See MObject#criteria and MObject#association on how to build criteria
  # and association filters for #get queries.
  def get(mobject)
    call(:get_m_objects, transform_param(__method__, mobject)) { |list|
      Get.new(list)
    }
  end

  def sync(operation, *mobjects) #:nodoc:
    # http://developers.marketo.com/documentation/soap/sync-mobjects/
    raise NotImplementedError,
      ":syncMObjects is not implemented in this version."
    response = call(
      :sync_m_objects,
      transform_param_list(__method__, mobjects)
    )
    extract_mobject_status_list(response)
  end

  # A response object to MObjects#get that includes the return count, the
  # new stream position, and the list of MObject records.
  class Get
    # The number of MObjects returned from MObjects#get.
    attr_reader :return_count
    # The stream position used for paging in MObjects#get.
    # This may be shared with each MObject in #mobjects.
    attr_reader :stream_position
    # The list of Marketo objects.
    attr_reader :mobjects

    def initialize(hash)
      @return_count = hash[:return_count].to_i
      @more = hash[:has_more]
      @stream_position = hash[:new_stream_position]
      objects = MarketoAPI.array(hash[:m_object_list])

      @mobjects = objects.map { |object|
        MarketoAPI::MObject.from_soap_hash(object[:m_object])
      }
    end

    # Returns +true+ if there are more objects to be returned.
    def more?
      !!@more
    end
  end

  private
  def extract_mobject_status_list(response)
    response = extract_from_response(response, :m_obj_status_list) { |resp|
      resp.map { |e| e[:m_object_status].values_at(:id, :status) }
    }.flatten
    Hash[*response]
  end
end
