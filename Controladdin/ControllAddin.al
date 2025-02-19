controladdin ControllAddin
{
    HorizontalShrink = true;
    HorizontalStretch = true;
    VerticalShrink = true;
    VerticalStretch = true;

    Scripts = 'src/main.js', 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.10.377/pdf.min.js','https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js';

    StyleSheets = 'src/style.css';

    procedure PassData(data1: Text);

    event StartAddin();
}