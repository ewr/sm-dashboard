module Listening
  class CleanUpResults
    include Interactor

    def call
      if context._results.aggregations.periods?
        clean = []
        context._results.aggregations.periods.buckets.each do |b|
          ts = Time.at(b['key'] / 1000)
          obj = self._clean(b,Hashie::Mash.new({time:ts.utc}))
          clean << obj
        end

        context.results = clean
      else
        context.results = self._clean(context._results.aggregations,Hashie::Mash.new())
      end
    end

    #----------

    def _clean(b,obj)
      if b.sessions?
        obj.sessions  = b.sessions.value
      end

      if b.duration?
        obj.duration  = b.duration.value
        obj.listeners = ( b.duration.value / context.period_length ).round()
      end

      if b.streams?
        obj.streams = {}
        b.streams.buckets.each do |sb|
          obj.streams[ sb['key'] ] = { requests:sb.doc_count, duration:sb.duration.value, listeners:(sb.duration.value / context.period_length).round() }
        end
      end

      if b.rewind?
        obj.rewind = {}
        b.rewind.buckets.each do |sr|
          obj.rewind[ sr['key'] ] = { duration:sr.duration.value, listeners:(sr.duration.value / context.period_length).round() }
        end
      end

      if b.clients?
        obj.clients = {}
        b.clients.buckets.each do |key,cli|
          obj.clients[ key ] = { duration:cli.duration.value, listeners:(cli.duration.value / context.period_length).round() }
        end
      end

      obj
    end
  end
end