controladdin Scan
{
    HorizontalShrink = true;
    HorizontalStretch = true;
    VerticalShrink = true;
    VerticalStretch = true;
    Scripts = 'Src/I_Scan-Documents/Resources/dynamsoft.webtwain.initiate.js',
              'Src/I_Scan-Documents/Resources/dynamsoft.webtwain.config.js',
              'Src/I_Scan-Documents/Resources/ScannerControl.js';
    // Scripts = 'src/Scan.Js', 'Src/Resources/dynamsoft.webtwain.initiate.js', 'Src/Resources/dynamsoft.webtwain.config.js', 'Src/Resources/src/dynamsoft.lts.js', 'Src/Resources/src/dynamsoft.webtwain.activex.js', 'Src/Resources/src/dynamsoft.webtwain.viewer.js';
    StyleSheets = 'Src/I_Scan-Documents/Resources/src/dynamsoft.webtwain.css', 'Src/I_Scan-Documents/Resources/src/dynamsoft.webtwain.viewer.css';
    // procedure Evaluate(jsCode: Text);

    event AcquireImage();
    event DownloadPDF();

    procedure LoadScannerUI();
}