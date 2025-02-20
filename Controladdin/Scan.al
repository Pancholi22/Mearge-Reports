controladdin Scan
{
    HorizontalShrink = true;
    HorizontalStretch = true;
    VerticalShrink = true;
    VerticalStretch = true;
    Scripts = 'Resources/dynamsoft.webtwain.initiate.js',
              'Resources/dynamsoft.webtwain.config.js',
              'Resources/ScannerControl.js';
    // Scripts = 'src/Scan.Js', 'Src/Resources/dynamsoft.webtwain.initiate.js', 'Src/Resources/dynamsoft.webtwain.config.js', 'Src/Resources/src/dynamsoft.lts.js', 'Src/Resources/src/dynamsoft.webtwain.activex.js', 'Src/Resources/src/dynamsoft.webtwain.viewer.js';
    StyleSheets = 'Resources/src/dynamsoft.webtwain.css', 'Resources/src/dynamsoft.webtwain.viewer.css';
    // procedure Evaluate(jsCode: Text);

    event AcquireImage();
    event DownloadPDF();

    procedure LoadScannerUI();
}