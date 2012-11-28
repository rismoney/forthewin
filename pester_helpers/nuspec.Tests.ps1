$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Validate-Schema.ps1"

Describe "Valid nuspec XML" {


  $dir = gci . -recurse
  $list=$dir | where {$_.extension -eq ".nuspec"} |select fullname
  foreach ($file in $list) {
    $str_filename=$file.fullname
    
    It "$str_filename should be a valid nuspec file" {
    $valid_nuspec = Validate-Schema $str_filename
    $valid_nuspec.should.be('True')
    }
  }
}