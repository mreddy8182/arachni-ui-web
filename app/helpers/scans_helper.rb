module ScansHelper

    def issues_to_graph_data( issues )
        graph_data = {
            severities:       {
                Arachni::Severity::HIGH          => 0,
                Arachni::Severity::MEDIUM        => 0,
                Arachni::Severity::LOW           => 0,
                Arachni::Severity::INFORMATIONAL => 0
            },
            issues:           {},
            elements:         {
                Arachni::Element::FORM   => 0,
                Arachni::Element::LINK   => 0,
                Arachni::Element::COOKIE => 0,
                Arachni::Element::HEADER => 0,
                Arachni::Element::BODY   => 0,
                Arachni::Element::PATH   => 0,
                Arachni::Element::SERVER => 0
            }
        }

        total_severities = 0
        total_elements   = 0

        issues.each.with_index do |issue, i|
            graph_data[:severities][issue.severity] += 1
            total_severities += 1

            graph_data[:issues][issue.name] ||= 0
            graph_data[:issues][issue.name] += 1

            graph_data[:elements][issue.elem] += 1
            total_elements += 1
        end

        graph_data[:severities].each do |severity, cnt|
            graph_data[:severities][severity] ||= 0
            begin
                graph_data[:severities][severity] = ((cnt / Float( total_severities ) ) * 100).to_i
            rescue
            end
        end

        graph_data[:elements].each do |elem, cnt|
            graph_data[:elements][elem] ||= 0
            begin
                graph_data[:elements][elem] = ((cnt / Float( total_elements ) ) * 100).to_i
            rescue
            end
        end

        graph_data
    end

    def issue_severity_to_alert( severity )
        ap severity.to_s.downcase.to_sym

        case severity.to_s.downcase.to_sym
            when :high
                'important'
            when :medium
                'warning'
            when :low
                'default'
            when :informational
                'info'
        end
    end

    def response_times_to_alert( time )
        time = time.to_f

        if time >= 1
            [ 'alert-error',
              'The server takes too long to respond to the scan requests,' +
                  ' this will severely diminish performance.']
        elsif (0.5..1.0).include?( time )
            [ 'alert-warning',
              'Server response times could be better but nothing to worry about yet.' ]
        else
            [ 'alert-success',
              'Server response times are excellent.' ]
        end
    end

    def concurrent_requests_to_alert( request_count, max )
        max = max.to_i
        request_count = request_count.to_i

        if request_count >= max
            [ 'alert-success',
              'HTTP request concurrency is operating at the allowed maximum.']
        elsif ((max/2)..max).include?( request_count )
            [ 'alert-warning',
              "HTTP request concurrency had to be throttled down (from the " +
                  "maximum of #{max}) due to high server response times, " +
                  'nothing to worry about yet though.' ]
        else
            [ 'alert-error',
              'HTTP request concurrency has been drastically throttled down ' +
                  "(from the maximum of #{max}) due to very high server" +
                  " response times, this will severely decrease performance."]
        end
    end
end
