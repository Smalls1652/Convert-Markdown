$mdFolder = Get-ChildItem -Path "././src/assets/content/markdown/"

foreach ($file in $mdFolder) {
    $pageData = ConvertFrom-Markdown -Path $file.FullName | Select-Object -ExpandProperty "HTML"
    $jsxImports = ""

    if (Test-Path "././src/assets/content/configs/$($file.BaseName).json") {
        $configJson = Get-Content -Path "././src/assets/content/configs/$($file.BaseName).json" | ConvertFrom-Json

        if ($configJson.elementChanges) {
            $optionVals = $configJson.elementChanges
        
            foreach ($element in $optionVals) {
                $pageData = $pageData `
                    -replace "<$($element.name)>", "<$($element.name) className=`"$($element.classes)`">" `
                    -replace "<thead>\n<tr>\n<th>No Header<\/th>\n<\/tr>\n<\/thead>", ""
                            
            }
        }
        if ($configJson.jsxImports) {
            foreach ($s in $configJson.jsxImports) {
                $jsxImports += "`n$($s)`n"
            }
        }
    }

    #Misc replacements
    $pageData = $pageData `
                    -replace "<p>\/\/StartCol(?'options'.*)\/\/<\/p>", '<Col${options}>' `
                    -replace "<p>\/\/EndCol\/\/<\/p>", "</Col>" `
                    -replace "<p>\/\/StartRow(?'options'.*)\/\/<\/p>", '<Row${options}>' `
                    -replace "<p>\/\/EndRow\/\/<\/p>", "</Row>" 
                
    $moduleCode = "import React, { Component } from 'react';
    $($jsxImports)

    class $((Get-Culture).TextInfo.ToTitleCase($file.BaseName)) extends Component {
        render() {
          return (
            <div>
            $($pageData)
            </div>
            )
        }};
        
        export default $((Get-Culture).TextInfo.ToTitleCase($file.BaseName));"

    $moduleCode | Out-File -FilePath "././src/assets/content/$($file.BaseName).js"
}