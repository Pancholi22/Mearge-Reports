page 50302 "Scan Page"
{
    Extensible = false;
    Caption = 'Scan Page';
    Editable = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            group(Control5)
            {
                ShowCaption = false;
            }
            usercontrol(WebPageViewer; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = All;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    CurrPage.WebPageViewer.Navigate(URL);
                end;

                trigger Callback(data: Text)
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        URL: Text;

    procedure SetURL(NavigateToURL: Text)
    begin
        URL := NavigateToURL;
    end;
}