page 50301 Scan
{
    ApplicationArea = All;
    Caption = 'Scan';
    PageType = Worksheet;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            usercontrol(scan; Scan)
            {

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Open Scanner UI")
            {
                Caption = 'Open Scanner UI';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    CurrPage.scan.LoadScannerUI();
                end;
            }
        }
    }

    var
        Data: Text;

    // trigger OnOpenPage()
    // begin
    //     Data := 'document.dispatchEvent(new Event("acquireImage"))';
    //     // CurrPage.Scan.Evaluate(Data);
    // end;

}
