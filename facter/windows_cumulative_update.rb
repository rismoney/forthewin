# vim: set ts=2 sw=2 ai et:
module MyOrg
  class CumulativeUpdate


    def self.value(os = Facter.value(:kernel))
      case os
        when 'windows'; windows_value
        when 'Linux'  ; linux_value
        else          ; 'unknown'
      end
    end

    def self.linux_value
      'n/a'
    end

    def self.windows_value
      require 'win32ole'
      product_name = Facter.value(:windows_product_name)
      case product_name
        when /Windows Server 2022/ ; updatename = "Cumulative Update for Windows Server 2022"
        when /Windows Server 2019/ ; updatename = "Cumulative Update for Windows Server 2019"
        when /Windows Server 2016/ ; updatename = "Cumulative Update for Windows Server 2016"
        else ; updatename = "Cumulative Update for Windows 10"
      end
      session = WIN32OLE.new("Microsoft.Update.Session")
      searcher = session.CreateUpdateSearcher
      updatecount = searcher.GetTotalHistoryCount()
      result=[]
      foo=searcher.QueryHistory(0,updatecount).each {|x| result << x.Title if x.Title.match(updatename)}
      result.first || "Cumulative Update not found"
    end
  end
end

Facter.add(:windows_cumulative_update) do
  setcode { MyOrg::CumulativeUpdate.value }
end
