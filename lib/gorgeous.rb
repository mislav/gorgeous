class Gorgeous
  def self.filename_to_format(filename)
    case File.extname(filename)
    when '.json' then :json
    when '.xml', '.html' then :xml
    when '.rb' then :ruby
    when '.yml', '.yaml' then :yaml
    when '.mail', '.email' then :email
    end
  end

  PRETTY = File.expand_path('../pretty.xslt', __FILE__)

  def self.pretty_xml(ugly)
    tidy = Nokogiri::XSLT File.read(PRETTY)
    tidy.transform(ugly).to_s
  end

  def self.convert_utf8(string, from_charset)
    if from_charset.nil? or from_charset.downcase.tr('-', '') == 'utf8'
      string
    else
      require 'iconv'
      Iconv.conv 'utf-8', from_charset, string
    end
  end

  def self.headers_from_mail(email)
    require 'active_support/ordered_hash'
    require 'active_support/core_ext/object/blank'

    address_field = lambda { |name|
      if field = email.header[name]
        values = field.addrs.map { |a|
          Mail::Encodings.unquote_and_convert_to(a.format, 'utf-8')
        }
        values.size < 2 ? values.first : values
      end
    }
    header_value = lambda { |name|
      field = email.header[name] and field.value.to_s
    }
    decoded_value = lambda { |name|
      field = email.header[name]
      Mail::Encodings.unquote_and_convert_to(field.value, 'utf-8') if field
    }

    data = ActiveSupport::OrderedHash.new
    data[:subject] = decoded_value['subject']
    data[:from] = address_field['from']
    data[:to] = address_field['to']
    data[:cc] = address_field['cc']
    data[:bcc] = address_field['bcc']
    data[:reply_to] = address_field['reply-to']
    data[:return_path] = email.return_path

    data[:message_id] = email.message_id
    data[:in_reply_to] = email.in_reply_to
    data[:references] = email.references

    data[:date] = email.date
    data[:sender] = address_field['sender']
    data[:delivered_to] = header_value['delivered-to']
    data[:original_sender] = header_value['x-original-sender']
    data[:content_type] = email.content_type.to_s.split(';', 2).first.presence
    data[:precedence] = header_value['precedence']

    data.tap { |hash| hash.reject! { |k,v| v.nil? } }
  end

  # adapted from webmock
  def self.http_from_string(raw_response)
    if raw_response.is_a?(IO)
      string = raw_response.read
      raw_response.close
      raw_response = string
    end
    socket = ::Net::BufferedIO.new(raw_response)
    response = ::Net::HTTPResponse.read_new(socket)
    transfer_encoding = response.delete('transfer-encoding') # chunks were already read
    response.reading_body(socket, true) {}

    options = {}
    options[:headers] = {}
    response.each_header { |name, value| options[:headers][name] = value }
    options[:headers]['transfer-encoding'] = transfer_encoding if transfer_encoding
    options[:body] = response.read_body
    options[:status] = [response.code.to_i, response.message]
    options
  end

  def initialize(input, options = {})
    @input = input
    @format = options[:format]
    @options = options
  end

  def filtered?
    !!@options[:query]
  end

  def to_s
    @str ||= @input.respond_to?(:read) ? @input.read : @input
  end

  def format
    @format ||= begin
      if @options[:filename]
        self.class.filename_to_format(@options[:filename])
      else
        guess_format
      end
    end
  end

  # typically hash or array
  def data
    apply_query case format
    when :xml
      require 'active_support/core_ext/hash/conversions'
      Hash.from_xml(to_s)
    when :json
      require 'yajl/json_gem'
      JSON.parse to_s
    when :yaml
      require 'yaml'
      YAML.load to_s
    when :email
      self.class.headers_from_mail to_mail
    when :ruby
      eval to_s # TODO: sandbox
    when :url
      require 'rack/utils'
      Rack::Utils.parse_nested_query(to_s.strip)
    when :http
      require 'net/http'
      self.class.http_from_string(to_s)[:headers]
    else
      raise ArgumentError, "don't know how to decode #{format}"
    end
  end

  def to_xml
    require 'nokogiri'
    Nokogiri to_s
  end

  def to_mail
    require 'mail'
    raw = to_s.lstrip
    raw << "\n" unless raw[-1, 1] == "\n"
    Mail.new raw
  end

  private

  def guess_format
    case to_s
    when /\A\s*[\[\{]/ then :json
    when /\A\s*</ then :xml
    when /\A---\s/ then :yaml
    when /\A\S+=\S+\Z/ then :url
    end
  end

  def apply_query(obj)
    if filtered?
      require 'active_support/core_ext/object/blank'
      query = @options[:query].dup
      while query.sub!(%r{(//?)(\w+)(?:\[(-?\d+)\])?}, '')
        obj = filter_resultset(obj, $2, $3, $1.length == 2)
        break if obj.nil?
      end
    end
    obj
  end

  def filter_resultset(obj, key, idx = nil, deep = false)
    if Array === obj
      obj.map { |o| filter_resultset(o, key, idx, deep) }.flatten.compact.presence
    elsif Hash === obj
      if deep
        result = obj.map do |k, value|
          if k.to_s == key.to_s then value
          else filter_resultset(value, key, nil, deep)
          end
        end.flatten.compact.presence
      else
        result = obj[key.to_s] || obj[key.to_sym]
      end
      result = result[idx.to_i] if result and idx
      result
    end
  end
end
