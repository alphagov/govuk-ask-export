module AskExport
  class BigQueryExport
    def self.call(*args)
      new(*args).call
    end

    def new(report = Report.new)
      @report = report
    end

    def call
      if report

    end
  end
end
